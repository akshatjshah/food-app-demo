import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../address/data/models/address.dart';
import '../../address/presentation/address_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../notifications/presentation/notifications_provider.dart';
import '../../subscription/presentation/subscription_provider.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import 'avatar_provider.dart';
import 'avatar_selection_page.dart';
import 'home_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(addressNotifierProvider).addresses.isEmpty &&
          !ref.read(addressNotifierProvider).isLoading) {
        ref.read(addressNotifierProvider.notifier).loadAddresses();
      }
      // Load the real unread badge (server-persisted across restarts),
      // filtered by the customer's notification preferences.
      ref.invalidate(unreadCountProvider);
      ref.invalidate(filteredUnreadCountProvider);
      // Shared favorites + subscription source of truth for home sections.
      try {
        ref.read(wishlistProvider.notifier).loadWishlist();
      } catch (_) {}
      try {
        ref.read(subscriptionNotifierProvider.notifier).loadMySubscriptions();
      } catch (_) {}
    });
  }

  String _formatAddress(Address address) {
    final parts = [
      address.addressLine1,
      if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
        address.addressLine2!,
      if (address.city != null && address.city!.isNotEmpty) address.city!,
      if (address.postalCode.isNotEmpty) address.postalCode,
    ];
    return parts.join(', ');
  }
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.itemCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, cartCount: cartCount),
                _buildSearchBar(context),
                _buildOfferCarousel(context, homeState),
                if (homeState.bannersLoading && homeState.banners.isEmpty) _buildSectionLoading(context),
                if (homeState.bannersError && homeState.banners.isEmpty) _buildSectionError(context, 'Banners unavailable'),
                _buildCategories(context, homeState),
                if (homeState.categoriesLoading && homeState.categories.isEmpty) _buildSectionLoading(context),
                if (homeState.categoriesError && homeState.categories.isEmpty) _buildSectionError(context, 'Categories unavailable'),
                _buildChefSpecials(context, homeState),
                if (homeState.bestsellersLoading && homeState.bestsellers.isEmpty) _buildSectionLoading(context),
                if (homeState.bestsellersError && homeState.bestsellers.isEmpty) _buildSectionError(context, 'Chef specials unavailable'),
                _buildHealthyPicks(context, homeState),
                if (homeState.healthyPicksLoading && homeState.healthyPicks.isEmpty) _buildSectionLoading(context),
                if (homeState.healthyPicksError && homeState.healthyPicks.isEmpty) _buildSectionError(context, 'Healthy picks unavailable'),
                _buildSubscriptionBanner(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAvatarSelector() async {
    final picked = await AvatarSelectionPage.show(context);
    if (picked == null) return;
    await ref.read(avatarProvider.notifier).setAvatar(picked);
  }

  Widget _buildHeader(BuildContext context, {int cartCount = 0}) {
    final avatarId = ref.watch(avatarProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openAvatarSelector,
                  behavior: HitTestBehavior.opaque,
                  child: Tooltip(
                    message: 'Choose your avatar',
                    child: Container(
                      width: 48,
                      height: 48,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                        child: SvgPicture.asset(
                          AvatarSelectionPage.assetForStatic(avatarId),
                          fit: BoxFit.cover,
                        ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: _buildLocationSection(context)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                    tooltip: 'Cart',
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => _openNotifications(context),
                    icon:
                        const Icon(Icons.notifications_outlined, size: 28),
                    tooltip: 'Notifications',
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final unreadAsync =
                          ref.watch(filteredUnreadCountProvider);
                      final count =
                          unreadAsync.valueOrNull ?? 0;
                      if (count <= 0) return const SizedBox.shrink();
                      return Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                                width: 1.5),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 18),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);
    final selected = addressState.selectedAddress;

    final String label;
    final String addressLine;
    if (addressState.isLoading && selected == null) {
      label = 'Location';
      addressLine = 'Finding your addresses...';
    } else if (selected != null) {
      label = selected.label;
      addressLine = _formatAddress(selected);
    } else if (addressState.errorMessage != null) {
      label = 'Set location';
      addressLine = 'Add your delivery address';
    } else {
      label = 'Set location';
      addressLine = 'Add your delivery address';
    }

    return InkWell(
      onTap: () => context.push('/location'),
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              addressLine,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.borderLight
                  : AppColors.borderDark,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.grey),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  'Search delicious healthy food...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              ),
              const Icon(Icons.tune_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCarousel(BuildContext context, HomeState homeState) {
    if (homeState.banners.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: AppSpacing.s24),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: homeState.banners.length,
        itemBuilder: (context, index) {
          final banner = homeState.banners[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (banner.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (banner.title != null)
                        Text(
                          banner.title!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context, HomeState homeState) {
    if (homeState.categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s24, right: AppSpacing.s24, top: AppSpacing.s32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            itemCount: homeState.categories.length,
            itemBuilder: (context, index) {
              final cat = homeState.categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.premiumShadow(),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: cat.icon != null
                          ? Center(
                              child: Text(cat.icon!, style: const TextStyle(fontSize: 28)),
                            )
                          : cat.imageUrl != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: cat.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Icon(Icons.restaurant, size: 24),
                                    errorWidget: (context, url, error) => const Icon(Icons.restaurant, size: 24),
                                  ),
                                )
                              : const Icon(Icons.restaurant, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChefSpecials(BuildContext context, HomeState homeState) {
    if (homeState.bestsellers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s24, right: AppSpacing.s24, top: AppSpacing.s32),
          child: Text(
            "Chef's Specials",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          itemCount: homeState.bestsellers.length,
          itemBuilder: (context, index) {
            final meal = homeState.bestsellers[index];
            final imageUrl = meal.imageUrls.isNotEmpty ? meal.imageUrls.first : '';
            final isFav = ref.watch(wishlistIdsProvider).contains(meal.id);
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: InkWell(
                onTap: () => context.push('/meal/${meal.id}'),
                borderRadius: BorderRadius.circular(AppRadius.r20),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(width: 80, height: 80, color: Colors.grey[200]),
                                errorWidget: (context, url, error) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.restaurant),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (meal.isVeg)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.success, width: 1.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(Icons.circle, size: 6, color: AppColors.success),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.error, width: 1.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(Icons.square, size: 6, color: AppColors.error),
                                  ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    meal.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await ref
                                          .read(wishlistProvider.notifier)
                                          .toggleWishlist(meal.id);
                                    } catch (_) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not update favorites. Try again.')),
                                        );
                                    }
                                  },
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFav ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (meal.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    meal.rating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('₹${meal.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).addItem(
                                            foodItemId: meal.id,
                                            quantity: 1,
                                          );
                                    },
                                    borderRadius: BorderRadius.circular(AppRadius.r12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(AppRadius.r12),
                                      ),
                                      child: const Text(
                                        'ADD',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
          },
        ),
      ],
    );
  }

  Widget _buildHealthyPicks(BuildContext context, HomeState homeState) {
    if (homeState.healthyPicks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s24, right: AppSpacing.s24, top: AppSpacing.s32),
          child: Text(
            "Healthy Picks",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            itemCount: homeState.healthyPicks.length,
            itemBuilder: (context, index) {
              final meal = homeState.healthyPicks[index];
              final imageUrl = meal.imageUrls.isNotEmpty ? meal.imageUrls.first : '';
              final isFav = ref.watch(wishlistIdsProvider).contains(meal.id);
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/meal/${meal.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[300]),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.restaurant),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.restaurant),
                                    ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      await ref
                                          .read(wishlistProvider.notifier)
                                          .toggleWishlist(meal.id);
                                    } catch (_) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not update favorites. Try again.')),
                                        );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isFav ? Colors.red : Colors.grey,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (meal.rating != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 12),
                                        const SizedBox(width: 2),
                                        Text(
                                          meal.rating!.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    '₹${meal.price.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionBanner(BuildContext context) {
    // Same source of truth as Profile header and the Subscription screen:
    // active subscription from subscriptionNotifierProvider (GET /subscriptions/my).
    final subState = ref.watch(subscriptionNotifierProvider);
    String? activeName;
    String? activeStatus;
    try {
      final active = subState.mySubscriptions.firstWhere(
        (s) => s.status == 'active',
      );
      activeName = active.subscription?.name;
      activeStatus = active.status;
    } catch (_) {
      activeName = null;
    }
    final hasActive = activeName != null && activeName.isNotEmpty;
    final bannerTitle = hasActive ? activeName : 'Subscribe & Save';
    final bannerSubtitle = hasActive
        ? 'Status: ${activeStatus ?? 'active'} — manage renewals, pauses and skipped meals.'
        : 'Get organic meals delivered daily at up to 20% discount.';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.s24),
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  bannerSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          ElevatedButton(
            onPressed: () => context.push('/my-subscriptions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r12)),
            ),
            child: Text(hasActive ? 'Manage' : 'View Plans', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s8),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner shimmer
          Container(
            height: 180,
            margin: const EdgeInsets.only(top: AppSpacing.s24),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 2,
              itemBuilder: (context, index) => Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                ),
              ),
            ),
          ),
          // Categories shimmer
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s24, right: AppSpacing.s24, top: AppSpacing.s32),
            child: Container(
              width: 200,
              height: 24,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 48,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Food list shimmer
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s24, right: AppSpacing.s24, top: AppSpacing.s32),
            child: Container(
              width: 180,
              height: 24,
              color: Colors.white,
            ),
          ),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 8),
            child: Container(
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.r20),
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Open the real notifications screen, then refresh the badge on return
  /// so read changes are reflected instantly.
  void _openNotifications(BuildContext context) {
    context.push('/notifications').then((_) {
      if (mounted) refreshNotifications(ref);
    });
  }
}
