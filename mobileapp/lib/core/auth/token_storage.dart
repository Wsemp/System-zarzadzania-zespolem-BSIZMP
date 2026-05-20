import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _rememberMeKey = 'remember_me';
  static const _savedUsernameKey = 'saved_username';
  static const _savedPasswordKey = 'saved_password';

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<String?> getAccess() => _storage.read(key: _accessKey);

  static Future<String?> getRefresh() => _storage.read(key: _refreshKey);

  static Future<void> saveUserId(int id) =>
      _storage.write(key: _userIdKey, value: id.toString());

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _savedUsernameKey, value: username);
    await _storage.write(key: _savedPasswordKey, value: password);
  }

  static Future<Map<String, String>?> getSavedCredentials() async {
    final username = await _storage.read(key: _savedUsernameKey);
    final password = await _storage.read(key: _savedPasswordKey);
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _savedUsernameKey);
    await _storage.delete(key: _savedPasswordKey);
  }

  // Usuwa tylko tokeny sesji — NIE usuwa zapisanych danych logowania
  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
  }
}
