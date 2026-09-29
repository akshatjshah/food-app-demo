import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import '../data/models/menu_food.dart';
import '../data/models/menu_category.dart';
import 'menu_providers.dart';

class MenuTab extends ConsumerStatefulWidget {
  const MenuTab({super.key});

  @override
  ConsumerState<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<MenuTab> {
  String _selectedCategory = 'all';
  bool _onlyVeg = false;
  String _sortBy = 'Popularity';
  bool _searchMode = false;
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();
  bool _wishlistLoaded = false;

  @override
  void initState() {
    super.initState();
    // Favorites persist server-side per customer: load once so menu cards
    // share the same state as Food Details, Home sections and My Favorites.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_wishlistLoaded) {
        _wishlistLoaded = true;
        try {
          ref.read(wishlistProvider.notifier).loadWishlist();
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<MenuFood> _applySorting(List<MenuFood> foods) {
    final sorted = List<MenuFood>.from(foods);
    switch (_sortBy) {
      case 'Price: Low to High':
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        sorted.sort((a, b) => b.price.compareTo(a.price));
      default:
        sorted.sort((a, b) => (b.reviewsCount).compareTo(a.reviewsCount));
    }
    return sorted;
  }

  void _applySearch(String raw) {
    final query = raw.trim();
    ref.read(foodListProvider.notifier).setSearch(query.isEmpty ? null : query);
  }

  void _onSearchChanged(String raw) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _applySearch(raw);
    });
  }

  void _onSearchSubmitted(String raw) {
    _searchDebounce?.cancel();
    _applySearch(raw);
  }

  void _toggleSearchMode() {
    _searchDebounce?.cancel();
    if (_searchMode) {
      _searchController.clear();
      ref.read(foodListProvider.notifier).setSearch(null);
      setState(() => _searchMode = false);
    } else {
      setState(() => _searchMode = true);
    }
  }

  void _selectCategory(MenuCategory category) {
    setState(() {
      _selectedCategory = category.id;
    });
    ref
        .read(foodListProvider.notifier)
        .setCategory(category.id == 'all' ? null : category.id);
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartState = ref.watch(cartProvider);

    final filteredFoods = _applySorting(foodState.foods);
    final isSearching =
        foodState.search != null && foodState.search!.isNotEmpty;

    // Always show "All" as the first category chip.
    final apiCategories = categoriesAsync.valueOrNull ?? const <MenuCategory>[];
    final categories = <MenuCategory>[
      const MenuCategory(id: 'all', name: 'All'),
      ...apiCategories.where((c) => c.id != 'all'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context, categories, cartState.itemCount),
            if (_searchMode) _buildSearchField(context),
            _buildFiltersRow(context),
            Expanded(
              child: foodState.isLoading
                  ? _buildLoadingShimmer(context)
                  : foodState.error != null
                      ? _buildErrorState(context, foodState.error!)
                      : filteredFoods.isEmpty
                          ? _buildEmptyState(context, isSearching: isSearching)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 24),
                              itemCount: filteredFoods.length,
                              itemBuilder: (context, index) {
                                final food = filteredFoods[index];
                                return _buildFoodCard(context, food)
                                    .animate()
                                    .fade(
                                        duration: 400.ms,
                                        delay: (index * 50).ms)
                                    .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        duration: 400.ms,
                                        delay: (index * 50).ms);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(
      BuildContext context, List<MenuCategory> categories, int cartCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s12, AppSpacing.s8, AppSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Parabdi Menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: _toggleSearchMode,
                tooltip: 'Search',
                icon: Icon(
                  _searchMode ? Icons.close_rounded : Icons.search_rounded,
                  size: 26,
                ),
              ),
              IconButton(
                onPressed: () => context.push('/cart'),
                tooltip: 'Cart',
                iconSize: 26,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryChip(context, categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, MenuCategory category) {
    final isSelected = _selectedCategory == category.id;
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).brightness == Brightness.light
                    ? AppColors.borderLight
                    : AppColors.borderDark,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.icon.isNotEmpty) ...[
              Text(category.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              category.name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.borderLight
                : AppColors.borderDark,
          ),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
          decoration: InputDecoration(
            hintText: 'Search foods...',
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchDebounce?.cancel();
                      _applySearch('');
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 1.5),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Veg Only',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
            selected: _onlyVeg,
            onSelected: (val) {
              setState(() {
                _onlyVeg = val;
              });
              ref
                  .read(foodListProvider.notifier)
                  .setVegFilter(val ? true : null);
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                _sortBy = val;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'Popularity', child: Text('Popularity')),
              const PopupMenuItem(
                  value: 'Price: Low to High',
                  child: Text('Price: Low to High')),
              const PopupMenuItem(
                  value: 'Price: High to Low',
                  child: Text('Price: High to Low')),
            ],
            child: Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sort: $_sortBy',
                      style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.s20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 16,
                        color: Colors.grey[300],
                      ),
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

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: AppSpacing.s16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.s16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(foodListProvider.notifier).loadFoods(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSearching}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.restaurant_rounded,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            isSearching ? 'No foods found' : 'No matching meals found',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.grey),
          ),
          if (isSearching) ...[
            const SizedBox(height: AppSpacing.s8),
            const Text('Try a different search term',
                style: TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, MenuFood food) {
    // Single source of truth: backend-backed wishlist, shared with
    // Food Details, Home sections and Profile → My Favorites.
    final favoriteIds = ref.watch(wishlistIdsProvider);
    final isWishlisted = favoriteIds.contains(food.id);
    final imageUrl =
        food.imageUrls.isNotEmpty ? food.imageUrls.first : '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: InkWell(
        onTap: () => context.push('/meal/${food.id}'),
        borderRadius: BorderRadius.circular(AppRadius.r20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppRadius.r16),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey[200]),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood,
                                color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: food.isVeg ? Colors.green : Colors.red,
                            width: 1.5),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color:
                              food.isVeg ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              await ref
                                  .read(wishlistProvider.notifier)
                                  .toggleWishlist(food.id);
                              if (!context.mounted) return;
                              final nowFav = ref
                                  .read(wishlistIdsProvider)
                                  .contains(food.id);
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
                                    content: Text(
                                        'Could not update favorites. Try again.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                            }
                          },
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isWishlisted ? Colors.red : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    if (food.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        food.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (food.rating != null) ...[
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(food.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(width: 4),
                        ],
                        if (food.reviewsCount > 0)
                          Text('(${food.reviewsCount})',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                        if (food.isBestseller) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('BESTSELLER',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹${food.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.primary),
                            ),
                            if (food.originalPrice != null &&
                                food.originalPrice! > food.price) ...[
                              const SizedBox(width: 6),
                              Text(
                                '₹${food.originalPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(cartProvider.notifier).addItem(
                                  foodItemId: food.id,
                                  quantity: 1,
                                );
                          },
                          borderRadius:
                              BorderRadius.circular(AppRadius.r12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r12),
                            ),
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
