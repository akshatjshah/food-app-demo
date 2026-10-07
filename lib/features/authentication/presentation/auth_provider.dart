import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/fcm_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../address/presentation/address_provider.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiClient.instance);
});

class AuthState {
  final bool isAuthenticated;
  final bool isVerifyingOtp;
  final String? phoneNumber;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isResending;
  final User? user;
  final String? devOtp;
  final int resendCooldownSeconds;

  AuthState({
    this.isAuthenticated = false,
    this.isVerifyingOtp = false,
    this.phoneNumber,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isResending = false,
    this.user,
    this.devOtp,
    this.resendCooldownSeconds = 0,
  });

  bool get canResend =>
      isVerifyingOtp &&
      !isLoading &&
      !isResending &&
      resendCooldownSeconds <= 0;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isVerifyingOtp,
    String? phoneNumber,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    bool? isLoading,
    bool? isResending,
    User? user,
    String? devOtp,
    bool clearDevOtp = false,
    int? resendCooldownSeconds,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isResending: isResending ?? this.isResending,
      user: user ?? this.user,
      devOtp: clearDevOtp ? null : (devOtp ?? this.devOtp),
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(AuthState()) {
    _init();
  }

  void _init() {
    final token = LocalStorage.getAccessToken();
    final userId = LocalStorage.getUserId();
    final userName = LocalStorage.getUserName();
    if (token != null && userId == null) {
      LocalStorage.clearAuth();
      return;
    }
    if (token != null && userId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: User(
          id: userId,
          phoneNumber: LocalStorage.getPhoneNumber() ?? '',
          fullName: userName,
          role: LocalStorage.getUserRole() ?? 'customer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _repo.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final data = await _repo.sendOtp(phone);
      state = state.copyWith(
        isLoading: false,
        isVerifyingOtp: true,
        phoneNumber: phone,
        devOtp: data['otp']?.toString(),
        resendCooldownSeconds: 30,
        clearError: true,
        successMessage: 'OTP sent successfully',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(e),
        clearSuccess: true,
      );
    }
  }

  Future<void> resendOtp() async {
    final phone = state.phoneNumber;
    if (phone == null || !state.isVerifyingOtp) return;
    if (state.isResending || state.resendCooldownSeconds > 0) return;

    state = state.copyWith(
      isResending: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final data = await _repo.sendOtp(phone);
      state = state.copyWith(
        isResending: false,
        isVerifyingOtp: true,
        phoneNumber: phone,
        devOtp: data['otp']?.toString(),
        resendCooldownSeconds: 30,
        clearError: true,
        successMessage: 'New OTP sent. Previous OTP is no longer valid.',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isResending: false,
        isVerifyingOtp: true,
        errorMessage: _extractError(e),
        clearSuccess: true,
      );
    } catch (_) {
      state = state.copyWith(
        isResending: false,
        isVerifyingOtp: true,
        errorMessage: 'Could not resend OTP. Please try again.',
        clearSuccess: true,
      );
    }
  }

  void tickResendCooldown() {
    if (state.resendCooldownSeconds <= 0) return;
    state = state.copyWith(resendCooldownSeconds: state.resendCooldownSeconds - 1);
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final data = await _repo.verifyOtp(state.phoneNumber!, otp);
      final user = User.fromJson(data['user']);
      final accessToken = data['accessToken'] ?? data['access_token'];
      final refreshToken = data['refreshToken'] ?? data['refresh_token'];
      await LocalStorage.setAccessToken(accessToken);
      await LocalStorage.setRefreshToken(refreshToken);
      await LocalStorage.setUserId(user.id);
      await LocalStorage.setUserName(user.fullName ?? '');
      await LocalStorage.setPhoneNumber(user.phoneNumber);
      await LocalStorage.setUserRole(user.role);
      _ref.read(addressNotifierProvider.notifier).clear();
      // Favorites are per-customer server-side: drop the previous user's
      // cached wishlist so the new session reloads its own.
      try {
        _ref.read(wishlistProvider.notifier).clear();
      } catch (_) {}
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isVerifyingOtp: false,
        user: user,
        clearDevOtp: true,
        clearError: true,
        clearSuccess: true,
        resendCooldownSeconds: 0,
      );
      // Register FCM device token against the new session (best effort).
      try {
        await FcmService.registerAfterLogin();
      } catch (_) {}
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isVerifyingOtp: true,
        errorMessage: _extractError(e),
        clearSuccess: true,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isVerifyingOtp: true,
        errorMessage: 'Invalid OTP. Please try again.',
        clearSuccess: true,
      );
      return false;
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repo.googleAuth(idToken);
      final user = User.fromJson(data['user']);
      final accessToken = data['accessToken'] ?? data['access_token'];
      final refreshToken = data['refreshToken'] ?? data['refresh_token'];
      await LocalStorage.setAccessToken(accessToken);
      await LocalStorage.setRefreshToken(refreshToken);
      await LocalStorage.setUserId(user.id);
      await LocalStorage.setUserName(user.fullName ?? '');
      await LocalStorage.setPhoneNumber(user.phoneNumber);
      await LocalStorage.setUserRole(user.role);
      _ref.read(addressNotifierProvider.notifier).clear();
      // Favorites are per-customer server-side: drop the previous user's
      // cached wishlist so the new session reloads its own.
      try {
        _ref.read(wishlistProvider.notifier).clear();
      } catch (_) {}
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        clearDevOtp: true,
      );
      try {
        await FcmService.registerAfterLogin();
      } catch (_) {}
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<void> logout() async {
    // Deactivate the device token server-side before clearing the session.
    try {
      await FcmService.deactivateOnLogout();
    } catch (_) {}
    await LocalStorage.clearAuth();
    _ref.read(addressNotifierProvider.notifier).clear();
    try {
      _ref.read(wishlistProvider.notifier).clear();
    } catch (_) {}
    state = AuthState();
    try {
      _repo.logout();
    } catch (_) {}
  }

  void loginAsGuest() {
    state = state.copyWith(
      isAuthenticated: true,
      user: User(
        id: 'guest',
        phoneNumber: '',
        fullName: 'Guest Foodie',
        role: 'guest',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
    LocalStorage.setUserName(user.fullName ?? '');
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetOtpState() {
    state = state.copyWith(
      isVerifyingOtp: false,
      phoneNumber: null,
      clearDevOtp: true,
      clearError: true,
      clearSuccess: true,
      resendCooldownSeconds: 0,
    );
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data;
      if (data['error'] is Map && data['error']['message'] != null) {
        return data['error']['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return e.error?.toString() ?? 'Something went wrong';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo, ref);
});
