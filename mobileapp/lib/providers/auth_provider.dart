import 'package:flutter/foundation.dart';
import '../core/auth/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _error;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> checkAuth() async {
    final rememberMe = await TokenStorage.getRememberMe();
    if (!rememberMe) {
      await TokenStorage.clear();
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }

    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final id = await TokenStorage.getUserId();
      if (id != null) {
        _user = await UserService.getUser(id);
      }
    } catch (_) {}
    _state = AuthState.authenticated;
    notifyListeners();
  }

  Future<bool> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await AuthService.login(username, password);
      await TokenStorage.saveRememberMe(rememberMe);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await AuthService.register(username, email, password);
      await TokenStorage.saveRememberMe(true);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Zwraca null przy sukcesie, lub komunikat błędu.
  Future<String?> forgotPassword(String email) async {
    try {
      await AuthService.forgotPassword(email);
      return null;
    } catch (e) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) msg = msg.substring(11);
      return msg;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    await TokenStorage.saveRememberMe(false);
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
