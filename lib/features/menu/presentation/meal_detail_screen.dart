import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import '../data/models/menu_food.dart';
import 'menu_providers.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;
  final Map<String, List<String>> _selectedCustomizations = {};

  @override
  void initState() {
    super.initState();
    // Share favorite state with menu cards, home sections and My Favorites.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(wishlistProvider.notifier).loadWishlist();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleCustomization(String groupId, String itemId, bool allowMultiple) {
    setState(() {
      if (allowMultiple) {
        final current = _selectedCustomizations[groupId] ?? [];
        if (current.contains(itemId)) {
          current.remove(itemId);
        } else {
          current.add(itemId);
        }
        _selectedCustomizations[groupId] = current;
      } else {
        _selectedCustomizations[groupId] = [itemId];
      }
    });
  }

  double _calculateCurrentPrice(MenuFood food) {
    double total = food.price;
    for (final entry in _selectedCustomizations.entries) {
      final group = food.customizationGroups
          .where((g) => g.id == entry.key)
          .firstOrNull;
      if (group != null) {
        for (final itemId in entry.value) {
          final item =
              group.items.where((i) => i.id == itemId).firstOrNull;
          if (item != null) {
            total += item.additionalPrice;
          }
        }
      }
    }
    return total * _quantity;
  }

  List<Map<String, dynamic>> _buildCustomizationPayload(MenuFood food) {
    final payload = <Map<String, dynamic>>[];
    for (final entry in _selectedCustomizations.entries) {
      for (final itemId in entry.value) {
        payload.add({
          'customization_group_id': entry.key,
          'customization_item_id': itemId,
        });
      }
    }
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final foodAsync = ref.watch(foodDetailProvider(widget.mealId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: foodAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: AppSpacing.s16),
              Text('Failed to load meal details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s12),
              ElevatedButton(
                onPressed: () => ref.invalidate(foodDetailProvider(widget.mealId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (food) => Stack(
          children: [
            AppPullToRefresh(
              onRefresh: () => _refreshMeal(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                _buildSliverAppBar(context, food),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFoodInfo(context, food),
                        if (food.customizationGroups.isNotEmpty) ...[
                          const Divider(height: 32),
                          ...food.customizationGroups.map((group) {
                            return _buildCustomizationGroup(context, food, group);
                          }),
                        ],
                        const Divider(height: 32),
                        _buildSpecialNotes(context),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
            _buildBottomActionBar(context, food),
          ],
        ),
      ),
    );
  }

  /// Re-fetches this dish from the backend (price, images, availability,
  /// customizations) via the existing food-detail provider. Failures keep
  /// the current dish on screen and surface a snackbar with Retry.
  Future<void> _refreshMeal() async {
    final provider = foodDetailProvider(widget.mealId);
    ref.invalidate(provider);
    try {
      await ref.read(provider.future);
    } catch (_) {
      if (!mounted) return;
      showRefreshError(
        context,
        message: 'Could not refresh dish. Showing saved data.',
        onRetry: _refreshMeal,
      );
    }
  }

  Widget _buildSliverAppBar(BuildContext context, MenuFood food) {
    final imageUrl =
        food.imageUrls.isNotEmpty ? food.imageUrls.first : '';
    final isFav = ref.watch(wishlistIdsProvider).contains(food.id);

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            child: IconButton(
              tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.red.shade300 : Colors.white,
                size: 20,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(wishlistProvider.notifier)
                      .toggleWishlist(food.id);
                  if (!context.mounted) return;
                  final nowFav =
                      ref.read(wishlistIdsProvider).contains(food.id);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(nowFav
                            ? 'Added to favorites'
                            : 'Removed from favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content:
                            Text('Could not update favorites. Try again.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                }
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'meal_${food.id}',
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[300]),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood,
                          size: 64, color: Colors.grey),
                    ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent, Colors.black45],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInfo(BuildContext context, MenuFood food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: food.isVeg
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle,
                      size: 10,
                      color: food.isVeg ? Colors.green : Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    food.isVeg ? 'VEG' : 'NON-VEG',
                    style: TextStyle(
                      color: food.isVeg ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (food.isBestseller)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BESTSELLER',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          food.name,
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          children: [
            if (food.rating != null) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                food.rating!.toStringAsFixed(1),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 8),
            ],
            if (food.reviewsCount > 0)
              Text(
                '(${food.reviewsCount} verified reviews)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        if (food.description != null) ...[
          const SizedBox(height: AppSpacing.s12),
          Text(
            food.description!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomizationGroup(
      BuildContext context, MenuFood food, CustomizationGroup group) {
    final selected = _selectedCustomizations[group.id] ?? [];
    final isRequired = group.minSelect > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                group.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (isRequired) ...[
                const SizedBox(width: 6),
                Text(
                  '(Required)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              if (group.maxSelect > 1)
                Text(
                  'Choose up to ${group.maxSelect}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          ...group.items.where((item) => item.isActive).map((item) {
            final isSelected = selected.contains(item.id);
            return CheckboxListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 14)),
                  if (item.additionalPrice > 0)
                    Text(
                      '+ ₹${item.additionalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                ],
              ),
              value: isSelected,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                _toggleCustomization(
                    group.id, item.id, group.maxSelect > 1);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpecialNotes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Special Instructions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'e.g. No green chili, make it less spicy...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, MenuFood food) {
    final currentPrice = _calculateCurrentPrice(food);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
          boxShadow: AppShadows.premiumShadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _quantity.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _quantity++);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final errorColor = Theme.of(context).colorScheme.error;
                  await ref.read(cartProvider.notifier).addItem(
                        foodItemId: food.id,
                        quantity: _quantity,
                        customizationItems:
                            _buildCustomizationPayload(food).isNotEmpty
                                ? _buildCustomizationPayload(food)
                                : null,
                        specialInstructions:
                            _notesController.text.isNotEmpty
                                ? _notesController.text
                                : null,
                      );
                  final error = ref.read(cartProvider).error;
                  if (!mounted) return;
                  if (error != null) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: errorColor,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    return;
                  }
                  if (context.mounted) context.pop();
                },
                child: Text(
                    'Add to Cart  •  ₹${currentPrice.toStringAsFixed(0)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
