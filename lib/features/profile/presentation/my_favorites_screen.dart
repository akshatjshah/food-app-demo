import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../wishlist/presentation/wishlist_screen.dart';

/// "My Favorites" — thin customer-facing alias over the existing
/// wishlist architecture. All data comes from [wishlistProvider]
/// (server-backed); no dummy data is ever shown.
class MyFavoritesScreen extends ConsumerStatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  ConsumerState<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends ConsumerState<MyFavoritesScreen> {
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
        title: const Text('My Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Same shared wishlist source as WishlistScreen; header refresh
          // covers non-scrollable states. Saved favorites are preserved on
          // failure with a snackbar instead.
          AppRefreshIconButton(
            tooltip: 'Refresh favorites',
            errorMessage:
                'Could not refresh favorites. Showing saved data.',
            onRefresh: () =>
                ref.read(wishlistProvider.notifier).loadWishlist(),
            hasError: () => ref.read(wishlistProvider).error != null,
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(WishlistState state) {
    // Full spinner only on initial load; silent refreshes keep the list so
    // the screen never gets stuck on infinite loading with items present.
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.error.withValues(alpha: 0.6)),
              const SizedBox(height: AppSpacing.s16),
              const Text('Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: AppSpacing.s8),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(wishlistProvider.notifier).loadWishlist(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      // Empty state: only the CTA button navigates (to Menu); the blank
      // background itself is intentionally NOT wrapped in any GestureDetector.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: AppSpacing.s16),
              const Text('No favorites yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: AppSpacing.s8),
              const Text(
                'Tap the heart on any dish to save it here for quick re-ordering.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Explore Menu'),
              ),
            ],
          ),
        ),
      );
    }
    return AppPullToRefresh(
      onRefresh: () => ref.read(wishlistProvider.notifier).loadWishlist(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        final food = item.foodItem;
        final imageUrl =
            food.imageUrls.isNotEmpty ? food.imageUrls.first : '';
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.s12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood_rounded,
                              color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood_rounded,
                            color: Colors.grey),
                      ),
              ),
            ),
            title: Text(food.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('₹${food.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13)),
            trailing: IconButton(
              tooltip: 'Remove from favorites',
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
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
                          content: Text('Removed from favorites')),
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
            ),
            onTap: () => context.push('/meal/${food.id}'),
          ),
        );
      },
      ),
    );
  }
}
