import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendOtp(String phoneNumber);
  Future<Map<String, dynamic>> verifyOtp({required String phoneNumber, required String otp});
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final response = await _client.post(
      ApiEndpoints.sendOtp,
      body: {'phoneNumber': phoneNumber},
    );
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({required String phoneNumber, required String otp}) async {
    final response = await _client.post(
      ApiEndpoints.verifyOtp,
      body: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      },
    );
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post(
      ApiEndpoints.refreshToken,
      body: {'refreshToken': refreshToken},
    );
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(
      ApiEndpoints.userProfile,
      requiresAuth: true,
    );
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final response = await _client.put(
      ApiEndpoints.userProfile,
      body: body,
      requiresAuth: true,
    );
    return response is Map<String, dynamic> ? response : {};
  }
}
