import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/auth/token_storage.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel> login(String username, String password) async {
    debugPrint('[AUTH] === LOGIN START: $username ===');

    late Map<String, dynamic> tokenData;
    try {
      tokenData = await ApiClient.post(ApiEndpoints.authLogin, {
        'username': username,
        'password': password,
      }, auth: false);
      debugPrint('[AUTH] Krok 1 OK – klucze: ${tokenData.keys.toList()}');
    } catch (e) {
      debugPrint('[AUTH] Krok 1 BŁĄD: $e');
      rethrow;
    }

    final access =
        (tokenData['access'] ?? tokenData['access_token'] ?? tokenData['token'])
            as String?;
    final refresh =
        (tokenData['refresh'] ?? tokenData['refresh_token'] ?? '') as String;

    if (access == null) {
      throw Exception('Serwer nie zwrócił tokenu dostępu');
    }

    await TokenStorage.saveTokens(access: access, refresh: refresh);

    late int userId;
    try {
      userId = _userIdFromToken(access);
      debugPrint('[AUTH] Krok 3: user_id=$userId');
    } catch (e) {
      debugPrint('[AUTH] Krok 3 BŁĄD (JWT decode): $e');
      rethrow;
    }
    await TokenStorage.saveUserId(userId);

    try {
      final userData = await ApiClient.get(ApiEndpoints.user(userId));
      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('[AUTH] Krok 4 BŁĄD (ignoruję): $e');
      return UserModel(
        id: userId,
        username: username,
        email: '',
        isStaff: false,
        isActive: true,
      );
    }
  }

  static int _userIdFromToken(String token) {
    final payload = token.split('.')[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final id = map['user_id'];
    return id is int ? id : int.parse(id.toString());
  }

  static Future<UserModel> register(
    String username,
    String email,
    String password,
  ) async {
    debugPrint('[AUTH] === REGISTER START: $username ===');
    try {
      await ApiClient.post(ApiEndpoints.register, {
        'username': username,
        'email': email,
        'password': password,
      }, auth: false);
    } catch (e) {
      debugPrint('[AUTH] Rejestracja BŁĄD: $e');
      rethrow;
    }
    return login(username, password);
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // 1. Pobierz userId z pamięci
    final userId = await TokenStorage.getUserId();
    if (userId == null) throw const UnauthorizedException();

    // 2. Pobierz username aktualnego użytkownika
    final userData = await ApiClient.get(ApiEndpoints.user(userId));
    final username = (userData as Map)['username'] as String;

    // 3. Zweryfikuj stare hasło przez próbę logowania
    try {
      await ApiClient.post(ApiEndpoints.authLogin, {
        'username': username,
        'password': oldPassword,
      }, auth: false);
    } catch (_) {
      throw const ValidationException('old_password: Nieprawidłowe hasło');
    }

    // 4. Zmień hasło przez PATCH /api/users/{id}/
    await ApiClient.patch(ApiEndpoints.user(userId), {'password': newPassword});
  }

  static Future<void> forgotPassword(String email) async {
    await ApiClient.post(ApiEndpoints.passwordReset, {
      'email': email,
    }, auth: false);
  }

  static Future<void> logout() => TokenStorage.clear();

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccess();
    return token != null;
  }
}
