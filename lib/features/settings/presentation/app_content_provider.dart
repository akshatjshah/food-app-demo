import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ApiClient.instance);
});

/// Dynamic business content from backend Settings (PostgreSQL).
/// Keys: home_promo_text, subscription_promo_text, about_us, contact_info.
/// Falls back to safe defaults when the setting is unavailable — never crashes.
class AppContentState {
  final Map<String, String> values;
  final bool isLoading;
  const AppContentState({this.values = const {}, this.isLoading = false});

  String? operator [](String key) => values[key];
}

class AppContentNotifier extends StateNotifier<AppContentState> {
  final SettingsRepository _repo;
  AppContentNotifier(this._repo) : super(const AppContentState());

  static const keys = [
    'home_promo_text',
    'subscription_promo_text',
    'about_us',
    'contact_info',
  ];

  Future<void> load() async {
    if (state.isLoading) return;
    state = AppContentState(values: state.values, isLoading: true);
    try {
      final vals = await _repo.getPublicValues(keys);
      if (vals.isEmpty && state.values.isNotEmpty) {
        // Fetch failed (offline/401) — keep last known values, never wipe.
        state = AppContentState(values: state.values);
        return;
      }
      // Overwrite with fresh server truth: keys absent from a successful
      // fetch were unpublished/deleted in Admin, so drop the stale copy.
      final next = Map<String, String>.from(state.values);
      for (final k in keys) {
        if (vals.containsKey(k)) {
          next[k] = vals[k]!;
        } else {
          next.remove(k);
        }
      }
      state = AppContentState(values: next);
    } catch (_) {
      state = AppContentState(values: state.values);
    }
  }

  /// Refetch latest published values when a screen finds its key missing
  /// (reopen/refresh without APK rebuild). No-op while a load is in flight.
  Future<void> loadIfMissing(String key) async {
    final v = state.values[key];
    if (v != null && v.isNotEmpty) return;
    await load();
  }

  Future<void> refreshKey(String key) async {
    try {
      final v = await _repo.getPublicValue(key);
      if (v != null && v.isNotEmpty) {
        state = AppContentState(values: {...state.values, key: v});
      }
    } catch (_) {}
  }
}

final appContentProvider =
    StateNotifierProvider<AppContentNotifier, AppContentState>((ref) {
  final notifier = AppContentNotifier(ref.read(settingsRepositoryProvider));
  // Lazy-load on first watch; screens also refresh on resume.
  Future.microtask(() => notifier.load());
  return notifier;
});
