class ApiConstants {
  ApiConstants._();

  /// Central API base URL for the entire app.
  ///
  /// Local Android development is permanent and IP-independent via
  /// `adb reverse tcp:3000 tcp:3000`, so the DEBUG default is loopback:
  ///   http://127.0.0.1:3000/api/v1
  /// No manual IP, no --dart-define, no router changes required.
  /// Optional override (CI/prod) at run/build time with:
  ///   `flutter run --dart-define=API_BASE_URL=http://HOST:3000/api/v1`
  static const String _defaultBaseUrl = 'http://127.0.0.1:3000/api/v1';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    return _defaultBaseUrl;
  }
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String googleAuth = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String fcmToken = '/auth/fcm-token';

  // Shorts
  static const String shorts = '/shorts';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
}
