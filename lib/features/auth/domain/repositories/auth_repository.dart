import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> login({
    required String email,
    required String password,
    String? captchaType,
    String? captchaToken,
  });
  Future<bool> submitTwoFactor({required String otpCode});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<bool> loginWithOAuth(String server);
  Future<bool> registerWithWebBrowser(String server);
}
