import 'package:dio/dio.dart';

/// Reads business-content settings from the backend Settings system
/// (single source of truth in PostgreSQL).
/// Public customer endpoint: GET /settings/public/:key and /settings/public
class SettingsRepository {
  final Dio _dio;
  SettingsRepository(this._dio);

  Future<String?> getPublicValue(String key) async {
    try {
      final res = await _dio.get('/settings/public/$key');
      final payload = res.data;
      final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
      if (data is Map) {
        final v = data['value'] ?? data['data']?['value'];
        if (v != null) return v.toString();
      }
      if (data is String) return data;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> getPublicValues(List<String> keys) async {
    final out = <String, String>{};
    for (final k in keys) {
      final v = await getPublicValue(k);
      if (v != null && v.isNotEmpty) out[k] = v;
    }
    // Bulk fallback: GET /settings/public returns all public keys at once.
    if (out.length < keys.length) {
      try {
        final res = await _dio.get('/settings/public');
        final payload = res.data;
        final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
        if (data is Map) {
          final dynamic list = data['settings'] ?? data;
          if (list is Map) {
            for (final k in keys) {
              final v = list[k];
              final s = v is Map ? v['value']?.toString() : v?.toString();
              if (s != null && s.isNotEmpty) out[k] = s;
            }
          }
        } else if (data is List) {
          for (final e in data) {
            if (e is Map && e['key'] != null && keys.contains(e['key'])) {
              out[e['key'].toString()] = (e['value'] ?? '').toString();
            }
          }
        }
      } catch (_) {}
    }
    return out;
  }
}
