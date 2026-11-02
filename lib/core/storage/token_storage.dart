import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyRole = 'auth_user_role';
  static const String _keyPhoneNumber = 'auth_phone_number';

  final SharedPreferences? prefs;

  TokenStorage({this.prefs});

  Future<SharedPreferences> get _instance async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    String? phoneNumber,
  }) async {
    final prefs = await _instance;
    await Future.wait([
      prefs.setString(_keyAccessToken, accessToken),
      prefs.setString(_keyRefreshToken, refreshToken),
      prefs.setString(_keyUserId, userId),
      prefs.setString(_keyRole, role),
      if (phoneNumber != null) prefs.setString(_keyPhoneNumber, phoneNumber),
    ]);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _instance;
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _instance;
    return prefs.getString(_keyRefreshToken);
  }

  Future<String?> getUserId() async {
    final prefs = await _instance;
    return prefs.getString(_keyUserId);
  }

  Future<String?> getRole() async {
    final prefs = await _instance;
    return prefs.getString(_keyRole);
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await _instance;
    return prefs.getString(_keyPhoneNumber);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await _instance;
    await Future.wait([
      prefs.remove(_keyAccessToken),
      prefs.remove(_keyRefreshToken),
      prefs.remove(_keyUserId),
      prefs.remove(_keyRole),
      prefs.remove(_keyPhoneNumber),
    ]);
  }
}
