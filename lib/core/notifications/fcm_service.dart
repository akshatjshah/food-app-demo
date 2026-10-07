import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../routes/app_router.dart';
import 'notification_realtime.dart';
import '../../features/notifications/data/models/notification_item.dart';
import '../../features/notifications/presentation/notifications_provider.dart';
import '../../features/orders/presentation/providers/orders_provider.dart';
import '../../features/settings/presentation/app_content_provider.dart';

/// Background/terminated handler — must be top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // No Firebase config (emulator/tests): inbox sync happens on resume.
  }
}

enum FcmInitStatus { ok, missingConfig, failed }

/// Central FCM + foreground notification pipeline.
/// - Foreground: updates notification/order state, bumps bell badge, shows
///   in-app banner, stays on current screen (no forced navigation).
/// - Background/terminated: OS shows the system push via FCM; tap opens the
///   app and the inbox already contains the record (backend is source of truth).
/// Firebase is optional at runtime: missing google-services config resolves to
/// [FcmInitStatus.missingConfig] and the app keeps working via inbox polling
/// on resume — push is never faked.
class FcmService {
  FcmService._();
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static bool _localInit = false;
  static ProviderContainer? _container;
  static final Set<String> _seenMessageIds = {};

  static void attachContainer(ProviderContainer c) => _container = c;

  static Future<FcmInitStatus> init({bool requestPermission = true}) async {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      debugPrint(
          'FCM: Firebase not configured (missing google-services.json/GoogleService-Info.plist). Push disabled; inbox remains source of truth.');
      return FcmInitStatus.missingConfig;
    }
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      if (requestPermission) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true, badge: true, sound: true,
        );
      }

      await _ensureLocalChannel();

      // Initialise tap handler BEFORE any show() call so foreground
      // heads-up taps always refresh the inbox.
      try {
        await _local.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
          onDidReceiveNotificationResponse: (r) => _refreshInbox(),
        );
      } catch (_) {}

      // Foreground messages: update state + banner, no navigation.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Tap on system notification (background/terminated): refresh inbox so
      // the tapped record is present; navigation handled by payload target.
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _onMessageOpened(initial);

      // Token refresh → re-register against backend.
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        _registerToken(t);
      });

      // Register current token if a session exists.
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);

      // Foreground local-notification taps (when we show heads-up via plugin).
      // (Initialised above before listeners.)

      return FcmInitStatus.ok;
    } catch (e) {
      debugPrint('FCM init failed: $e');
      return FcmInitStatus.failed;
    }
  }

  /// Call after login/session start: (re)registers the FCM token.
  static Future<void> registerAfterLogin() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);
    } catch (_) {}
  }

  /// Call on logout: deactivates token server-side (best effort).
  static Future<void> deactivateOnLogout() async {
    try {
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
      await ApiClient.instance.post('/auth/fcm-token/deactivate',
          data: token != null ? {'token': token} : {});
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    } catch (_) {}
  }

  static Future<void> _registerToken(String token) async {
    final access = LocalStorage.getAccessToken();
    if (access == null || access.isEmpty) return; // no session yet
    try {
      await ApiClient.instance.post('/auth/fcm-token', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return; // session invalid; skip
      debugPrint('FCM token registration failed: ${e.message}');
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  static Future<void> _ensureLocalChannel() async {
    if (_localInit) return;
    const channel = AndroidNotificationChannel(
      'parabdi_notifications',
      'Parabdi Notifications',
      description: 'Order updates, offers and announcements',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    try {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      _localInit = true;
    } catch (_) {}
  }

  static String? _refIdOf(Map<String, dynamic> data) {
    final v = data['reference_id'] ?? data['referenceId'];
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    // Prevent duplicates: same FCM messageId delivered twice shows one banner.
    final msgId = message.messageId ?? '${message.notification?.title}-${message.notification?.body}-${message.sentTime}';
    if (!_seenMessageIds.add(msgId)) return;
    _refreshInbox();
    final title = message.notification?.title ?? message.data['title'] ?? 'Parabdi';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type']?.toString();
    final refId = _refIdOf(message.data);
    // Push to the realtime bus so Home shows the bell-anchored popup
    // instantly (badge already invalidated above).
    try {
      NotificationRealtime.instance.pushExternal(NotificationItem(
        id: msgId,
        title: title.toString(),
        body: body.toString(),
        type: type,
        referenceId: refId,
        createdAt: DateTime.now(),
      ));
    } catch (_) {}
    // Fallback banner for non-Home screens; Home shows the bell popup.
    _showInAppBanner(title.toString(), body.toString(), type, refId);
  }

  /// Route a notification tap to the relevant screen. Order/delivery types
  /// with a reference open tracking; everything else opens the inbox.
  static void openNotificationTarget(String? type, String? refId) {
    try {
      final t = (type ?? '').toUpperCase();
      if (refId != null &&
          refId.isNotEmpty &&
          (t.contains('ORDER') ||
              t.contains('DELIVERY') ||
              t.contains('RIDER') ||
              t.contains('PAYMENT'))) {
        AppRouter.router.push('/track/$refId');
      } else if (refId != null &&
          refId.isNotEmpty &&
          (t.contains('SUBSCRIPTION'))) {
        AppRouter.router.push('/my-subscriptions');
      } else if (refId != null && refId.isNotEmpty && t.contains('MEAL')) {
        AppRouter.router.push('/meal/$refId');
      } else {
        AppRouter.router.push('/notifications');
      }
    } catch (_) {}
  }

  static void _onMessageOpened(RemoteMessage message) {
    // Deduplicate tap handling for the same push.
    final msgId = message.messageId ?? '';
    if (msgId.isNotEmpty && !_seenMessageIds.add('tap:$msgId')) {
      _refreshInbox();
      return;
    }
    _refreshInbox();
    // Deep-link to the relevant screen on system-notification tap.
    final refId = _refIdOf(message.data);
    final type = message.data['type']?.toString() ?? '';
    openNotificationTarget(type, refId);
  }

  static void _refreshInbox() {
    final c = _container;
    if (c == null) return;
    try {
      c.invalidate(notificationsFutureProvider);
      c.invalidate(unreadCountProvider);
      c.invalidate(filteredNotificationsProvider);
      c.invalidate(filteredUnreadCountProvider);
      c.read(ordersProvider.notifier).loadOrders();
      c.read(appContentProvider.notifier).load();
    } catch (_) {}
  }

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void _showInAppBanner(
      String title, String body, String? type, String? refId) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    final icon = type != null && type.contains('ORDER')
        ? Icons.receipt_long_outlined
        : Icons.local_offer_outlined;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => openNotificationTarget(type, refId),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (body.isNotEmpty)
                    Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
