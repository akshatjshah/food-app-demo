import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getAccessToken() => _prefs.getString('access_token');
  static Future<void> setAccessToken(String token) =>
      _prefs.setString('access_token', token);

  static String? getRefreshToken() => _prefs.getString('refresh_token');
  static Future<void> setRefreshToken(String token) =>
      _prefs.setString('refresh_token', token);

  static String? getUserId() => _prefs.getString('user_id');
  static Future<void> setUserId(String id) => _prefs.setString('user_id', id);

  static String? getUserName() => _prefs.getString('user_name');
  static Future<void> setUserName(String name) =>
      _prefs.setString('user_name', name);

  static String? getPhoneNumber() => _prefs.getString('phone_number');
  static Future<void> setPhoneNumber(String phone) =>
      _prefs.setString('phone_number', phone);

  static String? getUserRole() => _prefs.getString('user_role');
  static Future<void> setUserRole(String role) =>
      _prefs.setString('user_role', role);

  static String? get avatarStyle => _prefs.getString('avatar_style');
  static Future<void> setAvatarStyle(String style) =>
      _prefs.setString('avatar_style', style);

  static String? getAvatarForUser(String userId) =>
      _prefs.getString('avatar_$userId');
  static Future<void> setAvatarForUser(String userId, String avatarId) =>
      _prefs.setString('avatar_$userId', avatarId);

  static bool get hasSeenOnboarding =>
      _prefs.getBool('onboarding_complete') ?? false;
  static Future<void> setOnboardingComplete() =>
      _prefs.setBool('onboarding_complete', true);

  static bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  static Future<void> setDarkMode(bool value) =>
      _prefs.setBool('dark_mode', value);

  static String? get selectedAddressId =>
      _prefs.getString('selected_address_id');
  static String? get selectedAddressJson =>
      _prefs.getString('selected_address_json');
  static String? get selectedAddressUserId =>
      _prefs.getString('selected_address_user_id');

  static Future<void> setSelectedAddress({
    required String id,
    required String json,
    required String userId,
  }) async {
    await _prefs.setString('selected_address_id', id);
    await _prefs.setString('selected_address_json', json);
    await _prefs.setString('selected_address_user_id', userId);
  }

  static Future<void> clearSelectedAddress() async {
    await _prefs.remove('selected_address_id');
    await _prefs.remove('selected_address_json');
    await _prefs.remove('selected_address_user_id');
  }

  static bool get locationPromptShown =>
      _prefs.getBool('location_prompt_shown') ?? false;
  static Future<void> setLocationPromptShown() =>
      _prefs.setBool('location_prompt_shown', true);

  static String? get recentLocationsJson =>
      _prefs.getString('recent_locations_json');
  static Future<void> setRecentLocationsJson(String json) =>
      _prefs.setString('recent_locations_json', json);

  // Notification preferences — per customer. There is no backend prefs
  // endpoint, so choices are stored on-device keyed by userId and applied
  // to local notification presentation (list + badge filtering).
  // Transactional vs promotional stay logically separated in UI.
  // Legacy global keys are read as fallback for upgrades.
  static String _notifKey(String base) {
    final uid = getUserId();
    return uid == null || uid.isEmpty ? base : '${base}_$uid';
  }

  static bool _notifGet(String base) {
    if (_prefs.containsKey(_notifKey(base))) {
      return _prefs.getBool(_notifKey(base)) ?? true;
    }
    return _prefs.getBool(base) ?? true;
  }

  static Future<void> _notifSet(String base, bool v) =>
      _prefs.setBool(_notifKey(base), v);

  static bool get notifOrderUpdates => _notifGet('notif_order_updates');
  static Future<void> setNotifOrderUpdates(bool v) =>
      _notifSet('notif_order_updates', v);

  static bool get notifDeliveryUpdates =>
      _notifGet('notif_delivery_updates');
  static Future<void> setNotifDeliveryUpdates(bool v) =>
      _notifSet('notif_delivery_updates', v);

  static bool get notifSubscriptionUpdates =>
      _notifGet('notif_subscription_updates');
  static Future<void> setNotifSubscriptionUpdates(bool v) =>
      _notifSet('notif_subscription_updates', v);

  static bool get notifOffersPromotions =>
      _notifGet('notif_offers_promotions');
  static Future<void> setNotifOffersPromotions(bool v) =>
      _notifSet('notif_offers_promotions', v);

  // Local-only app rating (no general app-rating backend endpoint exists;
  // per-order reviews go through /reviews with an orderId). Scoped per
  // customer so shared devices don't leak ratings across accounts.
  static String _ratingKey(String base) {
    final uid = getUserId();
    return uid == null || uid.isEmpty ? base : '${base}_$uid';
  }

  static int get appRating {
    final key = _ratingKey('app_rating');
    if (_prefs.containsKey(key)) return _prefs.getInt(key) ?? 0;
    return _prefs.getInt('app_rating') ?? 0;
  }

  static Future<void> setAppRating(int v) =>
      _prefs.setInt(_ratingKey('app_rating'), v);
  static String? get appFeedback {
    final key = _ratingKey('app_feedback');
    if (_prefs.containsKey(key)) return _prefs.getString(key);
    return _prefs.getString('app_feedback');
  }

  static Future<void> setAppFeedback(String v) =>
      _prefs.setString(_ratingKey('app_feedback'), v);

  static Future<void> clearAuth() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_name');
    await _prefs.remove('phone_number');
    await _prefs.remove('user_role');
    await clearSelectedAddress();
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
