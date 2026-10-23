import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> sendOtp(String phoneNumber);
  Future<UserEntity> verifyOtp({required String phoneNumber, required String otp});
  Future<UserEntity?> getProfile();
  Future<UserEntity> updateProfile({
    String? firstName,
    String? lastName,
    UserAddressEntity? address,
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentToken();
}
