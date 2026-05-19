import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/auth/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel> login(String username, String password) async {
    debugPrint('[AUTH] === LOGIN START: $username ===');

    debugPrint('[AUTH] Krok 1: POST ${ApiEndpoints.authLogin}');
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
      debugPrint('[AUTH] Brak tokenu w odpowiedzi: $tokenData');
      throw Exception('Serwer nie zwrócił tokenu dostępu');
    }

    await TokenStorage.saveTokens(access: access, refresh: refresh);
    debugPrint('[AUTH] Krok 2: tokeny zapisane');

    late int userId;
    try {
      userId = _userIdFromToken(access);
      debugPrint('[AUTH] Krok 3: user_id=$userId');
    } catch (e) {
      debugPrint('[AUTH] Krok 3 BŁĄD (JWT decode): $e');
      rethrow;
    }
    await TokenStorage.saveUserId(userId);

    debugPrint('[AUTH] Krok 4: GET ${ApiEndpoints.user(userId)}');
    try {
      final userData = await ApiClient.get(ApiEndpoints.user(userId));
      debugPrint('[AUTH] Krok 4 OK');
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
    debugPrint('[AUTH] JWT payload keys: ${map.keys.toList()}');
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
      debugPrint('[AUTH] Rejestracja OK – logowanie...');
    } catch (e) {
      debugPrint('[AUTH] Rejestracja BŁĄD: $e');
      rethrow;
    }
    return login(username, password);
  }

  /// Zmiana hasła zalogowanego użytkownika.
  /// Backend musi obsługiwać POST /api/auth/change-password/
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    debugPrint('[AUTH] === CHANGE PASSWORD ===');
    await ApiClient.post(ApiEndpoints.changePassword, {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    debugPrint('[AUTH] Hasło zmienione OK');
  }

  static Future<void> logout() => TokenStorage.clear();

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccess();
    return token != null;
  }
}
