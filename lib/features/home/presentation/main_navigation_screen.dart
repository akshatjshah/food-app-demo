import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../address/presentation/address_provider.dart';
import '../../address/data/services/device_location_service.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../menu/presentation/menu_providers.dart';
import '../../orders/presentation/providers/orders_provider.dart';
import '../../subscription/presentation/subscription_provider.dart';
import 'compact_cart_bar.dart';
import 'home_provider.dart';
import 'home_tab.dart';
import '../../menu/presentation/menu_tab.dart';
import '../../subscription/presentation/subscription_tab.dart';
import '../../orders/presentation/orders_tab.dart';
import '../../profile/presentation/profile_tab.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const MenuTab(),
    const SubscriptionTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverTabIfNeeded(_currentIndex);
      if (LocalStorage.getAccessToken() != null) {
        ref.read(cartProvider.notifier).loadCart();
        ref.read(addressNotifierProvider.notifier).loadAddresses();
        DeviceLocationService.runLaunchLocationCheck(
          showTurnOnLocationDialog: _showTurnOnLocationDialog,
        );
      }
    });
  }

  /// Tabs live in an [IndexedStack], so they are built exactly once. If their
  /// first load ran while the backend was unreachable, the failed/empty result
  /// stayed cached forever (Menu showed "Failed to load foods", Home stayed
  /// blank). Re-check whenever a tab becomes visible and reload only when
  /// there is nothing to show.
  void _recoverTabIfNeeded(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (index) {
        case 0: // Home
          final home = ref.read(homeProvider);
          final empty = home.banners.isEmpty &&
              home.categories.isEmpty &&
              home.bestsellers.isEmpty &&
              home.healthyPicks.isEmpty;
          if (!home.isLoading && (home.errorMessage != null || empty)) {
            ref.read(homeProvider.notifier).refresh();
          }
          break;
        case 1: // Menu
          // Menu chips read the single shared category source (`homeProvider`,
          // same list as Home → Explore Categories). If that load failed or is
          // empty, refresh it so a stale chip (e.g. removed "Breads") cannot
          // linger in cache.
          final menuHome = ref.read(homeProvider);
          if (menuHome.categoriesError ||
              (menuHome.categories.isEmpty &&
                  !menuHome.categoriesLoading)) {
            ref.read(homeProvider.notifier).refresh();
          }
          final foods = ref.read(foodListProvider);
          if (!foods.isLoading && foods.error != null) {
            ref.read(foodListProvider.notifier).loadFoods();
          }
          break;
        case 2: // Subscription
          final sub = ref.read(subscriptionNotifierProvider);
          if (!sub.isLoading && sub.plans.isEmpty) {
            ref.read(subscriptionNotifierProvider.notifier).loadPlans();
          }
          break;
        case 3: // Orders
          final orders = ref.read(ordersProvider);
          if (!orders.isLoading &&
              (orders.errorMessage != null ||
                  (orders.ongoingOrders.isEmpty &&
                      orders.historyOrders.isEmpty))) {
            ref.read(ordersProvider.notifier).loadOrders();
          }
          break;
      }
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _recoverTabIfNeeded(index);
  }

  Future<bool> _showTurnOnLocationDialog() async {
    if (!mounted) return false;
    final enabled = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.location_on_rounded,
          color: AppColors.primary,
          size: 40,
        ),
        title: const Text(
          'Turn on location',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Parabdi uses your location to help select your delivery address.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
    if (enabled == true) {
      await DeviceLocationService.openLocationSettings();
      return true;
    }
    return false;
  }

  void _showCartError(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    // Errors only: success is communicated by the persistent compact
    // cart bar itself, so no black/success snackbar is ever shown.
    ref.listen(cartProvider, (previous, next) {
      final finishedAdd = previous?.isAdding == true && !next.isAdding;
      if (finishedAdd && next.error != null) {
        _showCartError(next.error!);
      }
    });

    final showCartBar = cartState.items.isNotEmpty && cartState.itemCount > 0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // Stack from bottom to top (inside this column):
      //   BOTTOM NAVIGATION  ←  COMPACT GREEN CART BAR  ←  (body/content above)
      // Wrapped in SafeArea so nothing sits under system gesture insets.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.borderLight
                  : AppColors.borderDark,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCartBar)
                CompactCartBar(
                  key: const ValueKey('compact_cart_bar'),
                  itemCount: cartState.itemCount,
                  total: cartState.subtotal,
                  onViewCart: () => context.push('/cart'),
                ).animate().slideY(
                      begin: 0.4,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: SizedBox(
                    height: kBottomNavigationBarHeight + 16,
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        _onTabSelected(index);
                      },
                      backgroundColor: Colors.transparent,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor: Colors.grey,
                      elevation: 0,
                      selectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      unselectedLabelStyle: const TextStyle(fontSize: 11),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          activeIcon: Icon(Icons.home_rounded),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.restaurant_outlined),
                          activeIcon: Icon(Icons.restaurant_rounded),
                          label: 'Menu',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.card_membership_outlined),
                          activeIcon: Icon(Icons.card_membership_rounded),
                          label: 'Subscription',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.receipt_long_outlined),
                          activeIcon: Icon(Icons.receipt_long_rounded),
                          label: 'Orders',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline_rounded),
                          activeIcon: Icon(Icons.person_rounded),
                          label: 'Profile',
                        ),
                      ],
                    ),
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
