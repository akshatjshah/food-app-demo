import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/splash_screen.dart';
import '../../features/authentication/presentation/onboarding_screen.dart';
import '../../features/authentication/presentation/auth_screen.dart';
import '../../features/home/presentation/main_navigation_screen.dart';
import '../../features/menu/presentation/meal_detail_screen.dart';
import '../../features/menu/presentation/search_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/orders/presentation/order_tracking_screen.dart';
import '../../features/address/presentation/addresses_screen.dart';
import '../../features/address/presentation/address_form_screen.dart';
import '../../features/address/presentation/address_prefill.dart';
import '../../features/address/presentation/select_location_screen.dart';
import '../../features/shorts/presentation/shorts_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/reviews/presentation/rating_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/notification_preferences_screen.dart';
import '../../features/profile/presentation/my_favorites_screen.dart';
import '../../features/profile/presentation/saved_payments_screen.dart';
import '../../features/profile/presentation/help_support_screen.dart';
import '../../features/profile/presentation/privacy_security_screen.dart';
import '../../features/profile/presentation/rate_parabdi_screen.dart';
import '../../features/profile/presentation/about_parabdi_screen.dart';
import '../../features/subscription/presentation/subscription_tab.dart';
import '../../features/subscription/presentation/subscription_detail_screen.dart';
import '../../features/subscription/presentation/subscription_provider.dart';
import '../../features/chef/presentation/chef_login_screen.dart';
import '../../features/chef/presentation/chef_dashboard_screen.dart';
import '../../features/chef/presentation/chef_orders_screen.dart';
import '../../features/chef/presentation/chef_inventory_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/meal/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MealDetailScreen(mealId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/track/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const SelectLocationScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        builder: (context, state) {
          final prefill = state.extra;
          return AddressFormScreen(
            prefill: prefill is AddressPrefill ? prefill : null,
          );
        },
      ),
      GoRoute(
        path: '/addresses/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddressFormScreen(addressId: id);
        },
      ),
      GoRoute(
        path: '/shorts',
        builder: (context, state) => const ShortsScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/rate/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final mealName = state.uri.queryParameters['meal'] ?? 'Gujarati Thali';
          return RatingScreen(orderId: orderId, mealName: mealName);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/my-subscriptions',
        builder: (context, state) =>
            const SubscriptionTab(showBackButton: true),
      ),
      GoRoute(
        path: '/profile/notification-preferences',
        builder: (context, state) =>
            const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/profile/favorites',
        builder: (context, state) => const MyFavoritesScreen(),
      ),
      GoRoute(
        path: '/profile/saved-payments',
        builder: (context, state) => const SavedPaymentsScreen(),
      ),
      GoRoute(
        path: '/profile/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/profile/privacy-security',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: '/profile/rate',
        builder: (context, state) => const RateParabdiScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        builder: (context, state) => const AboutParabdiScreen(),
      ),
      GoRoute(
        path: '/subscription/:planId',
        builder: (context, state) {
          final planId = state.pathParameters['planId']!;
          return _SubscriptionDetailWrapper(planId: planId);
        },
      ),
      // Chef Panel Routes
      GoRoute(
        path: '/chef/login',
        builder: (context, state) => const ChefLoginScreen(),
      ),
      GoRoute(
        path: '/chef/dashboard',
        builder: (context, state) => const ChefDashboardScreen(),
      ),
      GoRoute(
        path: '/chef/orders',
        builder: (context, state) {
          final initialTab = state.extra as int? ?? 0;
          return ChefOrdersScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/chef/inventory',
        builder: (context, state) => const ChefInventoryScreen(),
      ),
    ],
  );
}

class _SubscriptionDetailWrapper extends ConsumerWidget {
  final String planId;
  const _SubscriptionDetailWrapper({required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final plan = state.plans.where((p) => p.id == planId).firstOrNull;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription')),
        body: const Center(child: Text('Plan not found')),
      );
    }
    return SubscriptionDetailScreen(plan: plan);
  }
}
