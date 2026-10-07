import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/notifications/fcm_service.dart';
import 'core/notifications/notification_realtime.dart';
import 'core/routes/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/notifications/presentation/notifications_provider.dart';
import 'features/orders/presentation/providers/orders_provider.dart';
import 'features/settings/presentation/app_content_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  final container = ProviderContainer();
  FcmService.attachContainer(container);
  NotificationRealtime.instance.attachContainer(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ParabdiApp(),
    ),
  );
  // Best-effort: missing Firebase config resolves to missingConfig and the
  // app keeps working via inbox polling on resume — push is never faked.
  FcmService.init();
}

class _ForegroundRefreshObserver extends WidgetsBindingObserver {
  final ProviderContainer container;
  _ForegroundRefreshObserver(this.container);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Single refresh of server-backed state on foreground return (no polling).
      try {
        final token = LocalStorage.getAccessToken();
        if (token == null || token.isEmpty) return;
        container.invalidate(notificationsFutureProvider);
        container.invalidate(unreadCountProvider);
        container.invalidate(filteredNotificationsProvider);
        container.invalidate(filteredUnreadCountProvider);
        container.read(ordersProvider.notifier).loadOrders();
        container.read(appContentProvider.notifier).load();
      } catch (_) {}
    }
  }
}

class ParabdiApp extends ConsumerStatefulWidget {
  const ParabdiApp({super.key});

  @override
  ConsumerState<ParabdiApp> createState() => _ParabdiAppState();
}

class _ParabdiAppState extends ConsumerState<ParabdiApp> {
  _ForegroundRefreshObserver? _observer;
  bool _observerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ProviderScope.containerOf(context) subscribes to UncontrolledProviderScope,
    // so it must not run in initState. didChangeDependencies runs once the
    // inherited dependencies are available; the guard keeps it single-shot.
    if (_observerAttached) return;
    _observerAttached = true;
    _observer = _ForegroundRefreshObserver(ProviderScope.containerOf(context));
    WidgetsBinding.instance.addObserver(_observer!);
  }

  @override
  void dispose() {
    if (_observer != null) WidgetsBinding.instance.removeObserver(_observer!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard iPhone 13/14 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Parabdi Cloud Kitchen',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
          scaffoldMessengerKey: FcmService.messengerKey,
        );
      },
    );
  }
}
