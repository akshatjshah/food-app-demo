import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../home/data/models/home_data.dart';
import '../../home/presentation/home_provider.dart';
import '../data/models/menu_food.dart';
import 'search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the complete menu for the initial empty query.
      final state = ref.read(searchProvider);
      if (state.results.isEmpty && !state.isLoading) {
        ref.read(searchProvider.notifier).submitQuery(state.query);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    ref.read(searchProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    // Same single source as Home + Menu chips: active backend categories.
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search meals, categories...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          onChanged: (v) =>
              ref.read(searchProvider.notifier).updateQuery(v),
          onSubmitted: (v) =>
              ref.read(searchProvider.notifier).submitQuery(v),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          FilterChip(
            label: const Text('Veg Only',
                style: TextStyle(fontSize: 12)),
            selected: searchState.isVegOnly,
            onSelected: (_) =>
                ref.read(searchProvider.notifier).toggleVegOnly(),
            selectedColor: AppColors.success,
            labelStyle: TextStyle(
              color:
                  searchState.isVegOnly ? Colors.white : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(searchState, homeState),
    );
  }

  Widget _buildBody(SearchState searchState, HomeState homeState) {
    if (searchState.query.isEmpty) {
      if (searchState.error != null && searchState.results.isEmpty) {
        return _buildErrorState(searchState.error!);
      }
      if (searchState.isLoading && searchState.results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildSuggestions(homeState, searchState);
    }

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchState.error != null) {
      return _buildErrorState(searchState.error!);
    }
    if (searchState.results.isEmpty) {
      return _buildEmpty();
    }
    return _buildResults(searchState.results);
  }

  /// Shared refresh for search: re-fetches the single category source and
  /// re-runs the current query against the backend. Existing results stay
  /// visible if the refresh fails (notifiers preserve good data).
  Future<void> _refreshSearch() async {
    final query = ref.read(searchProvider).query;
    await ref.read(homeProvider.notifier).refresh();
    if (!mounted) return;
    // Re-runs the current query against the backend (fire-and-forget:
    // the provider streams loading/results/error states itself).
    ref.read(searchProvider.notifier).submitQuery(query);
    if (!mounted) return;
    final searchState = ref.read(searchProvider);
    final homeState = ref.read(homeProvider);
    if ((searchState.error != null && searchState.results.isEmpty) ||
        (homeState.categoriesError && homeState.categories.isEmpty)) {
      showRefreshError(
        context,
        message: 'Could not refresh search. Showing saved data.',
        onRetry: _refreshSearch,
      );
    }
  }

  Widget _buildSuggestions(HomeState homeState, SearchState searchState) {
    final foods = searchState.results;
    final categories = homeState.categories;

    return AppPullToRefresh(
      onRefresh: _refreshSearch,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        const Text('Popular Searches',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Gujarati Thali', 'Paneer', 'Dal', 'Biryani', 'Roti']
              .map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () {
                _controller.text = term;
                ref
                    .read(searchProvider.notifier)
                    .submitQuery(term);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.s24),
        const Text('Browse Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSpacing.s12),
        // Single source of truth (same list as Home + Menu chips): active
        // backend categories in admin order. No hardcoded fallback — an
        // error shows a retry affordance instead of a fake category list.
        if (homeState.categoriesLoading && categories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (homeState.categoriesError && categories.isEmpty)
          Row(
            children: [
              const Expanded(
                child: Text('Categories unavailable',
                    style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(homeProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          )
        else
          Column(
            children: categories
                .where((c) => c.id != 'all')
                .map((cat) {
              return _buildCategoryTile(context, cat);
            }).toList(),
          ),
        const SizedBox(height: AppSpacing.s24),
        const Text('All Meals',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSpacing.s12),
        if (foods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
            child: Center(
              child: Text('No foods found',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
          )
        else
          ...foods.map(_buildFoodCard),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, HomeCategory cat) {
    Widget leading;
    if (cat.icon != null && cat.icon!.isNotEmpty) {
      leading = Text(cat.icon!, style: const TextStyle(fontSize: 24));
    } else if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
      leading = ClipOval(
        child: CachedNetworkImage(
          imageUrl: cat.imageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(width: 40, height: 40, color: Colors.grey[200]),
          errorWidget: (context, url, error) =>
              const Icon(Icons.category, size: 24),
        ),
      );
    } else {
      leading = const Icon(Icons.category, size: 24);
    }
    return ListTile(
      leading: leading,
      title: Text(cat.name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        _controller.text = cat.name;
        ref.read(searchProvider.notifier).submitQuery(cat.name);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 80, color: Colors.redAccent),
          const SizedBox(height: AppSpacing.s16),
          Text(error,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSpacing.s8),
          const Text('Try a different search term',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: AppSpacing.s16),
          const Text('No foods found',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: AppSpacing.s8),
          const Text('Try a different search term',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResults(List<MenuFood> results) {
    return AppPullToRefresh(
      onRefresh: _refreshSearch,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final food = results[index];
          return _buildFoodCard(food);
        },
      ),
    );
  }

  Widget _buildFoodCard(MenuFood food) {
    final imageUrl =
        food.imageUrls.isNotEmpty ? food.imageUrls.first : '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r16),
        onTap: () => context.push('/meal/${food.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppRadius.r12),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey[200]),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood,
                            color: Colors.grey),
                      ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (food.isVeg)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.success,
                                  width: 1.5),
                              borderRadius:
                                  BorderRadius.circular(3),
                            ),
                            child: const Icon(Icons.circle,
                                size: 8, color: AppColors.success),
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(food.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${food.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        if (food.originalPrice != null &&
                            food.originalPrice! > food.price) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${food.originalPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              decoration:
                                  TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (food.rating != null) ...[
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(food.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
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
