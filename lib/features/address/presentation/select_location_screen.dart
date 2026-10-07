import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../data/models/address.dart';
import '../data/models/recent_location.dart';
import '../data/repositories/places_repository.dart';
import 'address_actions.dart';
import 'address_prefill.dart';
import 'address_provider.dart';
import 'recent_locations_provider.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final _searchController = TextEditingController();
  final _debouncer = _SearchDebouncer(const Duration(milliseconds: 400));

  bool _isSearching = false;
  List<PlaceResult> _results = const [];
  String? _searchError;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(addressNotifierProvider);
      if (state.addresses.isEmpty && !state.isLoading) {
        ref.read(addressNotifierProvider.notifier).loadAddresses();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _debouncer.cancel();
      if (_isSearching || _results.isNotEmpty || _searchError != null) {
        setState(() {
          _isSearching = false;
          _results = const [];
          _searchError = null;
          _activeQuery = '';
        });
      }
      return;
    }
    _debouncer.run(_performSearch, query);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
      _activeQuery = query.trim();
    });
    try {
      final places = ref.read(placesRepositoryProvider);
      final results = await places.searchPlaces(query.trim());
      if (!mounted || _activeQuery != query.trim()) return;
      setState(() {
        _isSearching = false;
        _results = results;
        if (results.isEmpty) {
          _searchError = 'No places found for "$query". Try another search.';
        }
      });
    } catch (_) {
      if (!mounted || _activeQuery != query.trim()) return;
      setState(() {
        _isSearching = false;
        _results = const [];
        _searchError =
            'Could not search places right now. Check your connection.';
      });
    }
  }

  void _popOrHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _selectSavedAddress(Address address) {
    ref.read(addressNotifierProvider.notifier).selectAddress(address);
    _popOrHome();
  }

  Future<void> _onPlaceTapped(PlaceResult place) async {
    final title = place.name.trim().isNotEmpty
        ? place.name
        : (place.address.trim().isNotEmpty ? place.address : 'Selected place');
    final address = place.address;

    final recent = RecentLocation(
      title: title,
      address: address,
      latitude: place.latitude,
      longitude: place.longitude,
    );
    await ref.read(recentLocationsProvider.notifier).add(recent);

    if (!mounted) return;

    final saved = ref.read(addressNotifierProvider).addresses;
    Address? match;
    for (final a in saved) {
      final dLat = (a.latitude - place.latitude).abs();
      final dLng = (a.longitude - place.longitude).abs();
      if (dLat <= 0.0005 && dLng <= 0.0005) {
        match = a;
        break;
      }
    }

    if (match != null) {
      ref.read(addressNotifierProvider.notifier).selectAddress(match);
      _popOrHome();
      return;
    }

    context.push(
      '/addresses/add',
      extra: AddressPrefill(
        latitude: place.latitude,
        longitude: place.longitude,
        addressLine1: address.isNotEmpty ? address : title,
        title: title,
        reverseGeocode: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);
    final recents = ref.watch(recentLocationsProvider);
    final searching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: _popOrHome,
        ),
        actions: [
          // Re-fetches saved addresses from the backend (same loader used
          // on init/retry). Saved results are preserved on failure.
          AppRefreshIconButton(
            tooltip: 'Refresh addresses',
            errorMessage:
                'Could not refresh addresses. Showing saved data.',
            onRefresh: () =>
                ref.read(addressNotifierProvider.notifier).loadAddresses(),
            hasError: () =>
                ref.read(addressNotifierProvider).errorMessage != null,
          ),
        ],
      ),
      body: SafeArea(
        child: AppPullToRefresh(
          onRefresh: () =>
              ref.read(addressNotifierProvider.notifier).loadAddresses(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            _buildSearchField(),
            const SizedBox(height: AppSpacing.s16),
            _buildQuickActions(),
            if (searching) ...[
              const SizedBox(height: AppSpacing.s24),
              _buildSearchResults(),
            ] else ...[
              const SizedBox(height: AppSpacing.s24),
              _buildSavedSection(addressState),
              if (recents.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s24),
                _buildRecentsSection(recents),
              ],
            ],
            const SizedBox(height: AppSpacing.s32),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search for an area, street or landmark...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: _searchController.clear,
              )
            : const Icon(Icons.mic_rounded, color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: AppSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuickActionButton(
          icon: Icons.add_location_alt_rounded,
          label: 'Add New Address',
          onTap: () => context.push('/addresses/add'),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Text(
            _searchError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    if (_results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search results',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.s8),
        ..._results.map(
          (place) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.location_on_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              place.address,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onPlaceTapped(place),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedSection(AddressState state) {
    final preview = state.addresses.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved addresses',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (state.addresses.length > preview.length || preview.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/addresses'),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        if (state.isLoading && state.addresses.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.errorMessage != null && state.addresses.isEmpty)
          _ErrorRetry(
            message: state.errorMessage!,
            onRetry: () =>
                ref.read(addressNotifierProvider.notifier).loadAddresses(),
          )
        else if (state.addresses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Text(
              'No saved addresses yet. Search above or use your current location to add one.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ...preview.map((address) {
            final isSelected = address.id == state.selectedAddress?.id;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Icon(
                      addressLabelIcon(address.label),
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    address.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    formatAddress(address),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    tooltip: 'Address actions',
                    onPressed: () => showAddressActionMenu(
                      context,
                      ref,
                      address,
                      isSelected: isSelected,
                    ),
                  ),
                  onTap: () => _selectSavedAddress(address),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRecentsSection(List<RecentLocation> recents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently searched',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(recentLocationsProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        ...recents.map(
          (recent) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_rounded, color: Colors.grey),
            title: Text(
              recent.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: recent.address.isNotEmpty
                ? Text(
                    recent.address,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () =>
                  ref.read(recentLocationsProvider.notifier).remove(recent),
            ),
            onTap: () {
              if (recent.latitude == null || recent.longitude == null) return;
              context.push(
                '/addresses/add',
                extra: AddressPrefill(
                  latitude: recent.latitude,
                  longitude: recent.longitude,
                  addressLine1: recent.address.isNotEmpty
                      ? recent.address
                      : recent.title,
                  title: recent.title,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.error_outline_rounded,
            size: 40, color: Colors.grey.shade400),
        const SizedBox(height: AppSpacing.s12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.s16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _SearchDebouncer {
  _SearchDebouncer(this.delay);
  final Duration delay;
  int _token = 0;

  void run(void Function(String) action, String query) {
    final current = ++_token;
    Future.delayed(delay, () {
      if (current == _token) action(query);
    });
  }

  void cancel() {
    _token++;
  }
}
