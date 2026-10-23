import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyAccessToken = 'ebs_access_token';
  static const String _keyRefreshToken = 'ebs_refresh_token';
  static const String _keyUserPhone = 'ebs_user_phone';
  static const String _keyUserName = 'ebs_user_name';
  static const String _keyUserId = 'ebs_user_id';

  final SharedPreferences? _prefs;

  TokenStorage([this._prefs]);

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage(prefs);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  Future<void> saveUserSession({
    required String accessToken,
    String? refreshToken,
    String? phone,
    String? name,
    String? userId,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null) await prefs.setString(_keyRefreshToken, refreshToken);
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    if (name != null) await prefs.setString(_keyUserName, name);
    if (userId != null) await prefs.setString(_keyUserId, userId);
  }

  Future<String?> getAccessToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<String?> getUserPhone() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPhone);
  }

  Future<String?> getUserName() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<String?> getUserId() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserId);
  }
}
