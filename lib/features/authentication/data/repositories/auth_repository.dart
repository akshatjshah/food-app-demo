import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final response = await _dio.post(ApiConstants.sendOtp, data: {
      'phoneNumber': phoneNumber,
    });
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final response = await _dio.post(ApiConstants.verifyOtp, data: {
      'phoneNumber': phoneNumber,
      'otp': otp,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> googleAuth(String idToken, {String? fcmToken}) async {
    final data = <String, dynamic>{'idToken': idToken};
    if (fcmToken != null) data['fcmToken'] = fcmToken;
    final response = await _dio.post(ApiConstants.googleAuth, data: data);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> refreshTokens(String refreshToken) async {
    final response = await _dio.post(ApiConstants.refreshToken, data: {
      'refreshToken': refreshToken,
    });
    return response.data['data'];
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<User> getProfile() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data['data']);
  }

  Future<void> updateProfile({String? fullName, String? email}) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (email != null) data['email'] = email;
    await _dio.patch(ApiConstants.profile, data: data);
  }

  Future<void> saveFcmToken(String token) async {
    await _dio.post(ApiConstants.fcmToken, data: {
      'token': token,
      'platform': 'android',
    });
  }
}
