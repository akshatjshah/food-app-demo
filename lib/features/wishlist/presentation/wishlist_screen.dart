import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/wishlist_item.dart';
import '../data/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ApiClient.instance);
});

class WishlistState {
  final List<WishlistItem> items;
  final bool isLoading;
  final String? error;
  // Ids optimistically marked favorite before the silent reload finishes,
  // so hearts update immediately even though POST carries no food payload.
  final Set<String> optimisticIds;

  WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.optimisticIds = const {},
  });

  WishlistState copyWith({
    List<WishlistItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? optimisticIds,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      optimisticIds: optimisticIds ?? this.optimisticIds,
    );
  }
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistRepository _repo;

  WishlistNotifier(this._repo) : super(WishlistState());

  Future<void> loadWishlist({bool silent = false}) async {
    // Silent background refresh must never flash a full-screen spinner
    // over an existing list (e.g. right after tapping a heart).
    final showSpinner = !silent || state.items.isEmpty;
    if (showSpinner) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }
    try {
      final items = await _repo.getWishlist();
      state = state.copyWith(
        items: items,
        isLoading: false,
        optimisticIds: const {},
        clearError: true,
      );
    } catch (e) {
      // Catch ALL throwables (TypeError is Error, not Exception) so the
      // favorites screen can never get stuck on an infinite spinner.
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Returns true when the item ends up favorited, false when unfavorited.
  /// Throws on API failure after reverting any optimistic change.
  Future<bool> toggleWishlist(String foodItemId) async {
    final wasFav = state.items.any((i) => i.foodItem.id == foodItemId) ||
        state.optimisticIds.contains(foodItemId);
    if (!wasFav) {
      // Optimistic add: heart turns red immediately.
      state = state.copyWith(
        optimisticIds: {...state.optimisticIds, foodItemId},
        clearError: true,
      );
    } else {
      // Optimistic remove: heart clears immediately.
      state = state.copyWith(
        items: state.items
            .where((item) => item.foodItem.id != foodItemId)
            .toList(),
        optimisticIds:
            state.optimisticIds.where((id) => id != foodItemId).toSet(),
        clearError: true,
      );
    }
    try {
      final added = await _repo.toggleWishlist(foodItemId);
      if (!added) {
        // Server confirms removal: ensure local state matches.
        state = state.copyWith(
          items: state.items
              .where((item) => item.foodItem.id != foodItemId)
              .toList(),
          optimisticIds:
              state.optimisticIds.where((id) => id != foodItemId).toSet(),
        );
        return false;
      } else {
        // Server confirms add: silent reload brings the real payload
        // without flashing a full-screen spinner.
        await loadWishlist(silent: true);
        return true;
      }
    } catch (e) {
      // Revert optimistic change so heart state stays truthful.
      if (!wasFav) {
        state = state.copyWith(
          optimisticIds:
              state.optimisticIds.where((id) => id != foodItemId).toSet(),
          error: e.toString(),
        );
      } else {
        // Re-fetch to restore the removed row; on failure keep error.
        try {
          await loadWishlist(silent: true);
        } catch (_) {}
        state = state.copyWith(error: e.toString());
      }
      rethrow;
    }
  }

  /// Drop cached items on logout/login so one customer never sees another's
  /// favorites. Server data is per-user; this only clears the local copy.
  void clear() {
    state = WishlistState();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final repo = ref.read(wishlistRepositoryProvider);
  return WishlistNotifier(repo);
});

/// Shared favorite-id set so menu cards, food details, home sections and
/// My Favorites all render the same favorite state from one source of truth
/// (server items plus immediately-applied optimistic taps).
final wishlistIdsProvider = Provider<Set<String>>((ref) {
  final s = ref.watch(wishlistProvider);
  return {...s.items.map((i) => i.foodItem.id), ...s.optimisticIds};
});

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(WishlistState state) {
    // Full shimmer only on initial load; silent refreshes keep the list.
    if (state.isLoading && state.items.isEmpty) {
      return _buildLoadingShimmer();
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton(
              onPressed: () => ref.read(wishlistProvider.notifier).loadWishlist(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.s16),
            const Text('Your wishlist is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: AppSpacing.s8),
            const Text('Save your favorite meals here', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _buildWishlistCard(item);
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 120, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 14, width: 60, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistCard(WishlistItem item) {
    final food = item.foodItem;
    final imageUrl = food.imageUrls.isNotEmpty ? food.imageUrls.first : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: food.isVeg ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(food.id);
                        if (!context.mounted) return;
                        messenger
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                                content: Text('Removed from wishlist')),
                          );
                      } catch (_) {
                        if (!context.mounted) return;
                        messenger
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Could not update favorites. Try again.')),
                          );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                    ),
                  ),
                ),
                if (food.rating != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            food.rating!.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\u20B9${food.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
