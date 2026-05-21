import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _loading = false;
  String? _error;
  bool _polling = false;
  Timer? _timer;

  List<NotificationModel> get notifications =>
      _notifications.where((n) => n.isRelevant).toList();
  List<NotificationModel> get unread =>
      notifications.where((n) => !n.isRead).toList();
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => unread.length;

  void startPolling() {
    if (_polling) return;
    _polling = true;
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _silentLoad());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _polling = false;
  }

  Future<void> _silentLoad() async {
    try {
      final fresh = await NotificationService.getNotifications();
      _notifications = fresh;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await NotificationService.getNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      await NotificationService.markAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notifications = List.from(_notifications)
          ..[idx] = _notifications[idx].copyWith(isRead: true);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = unread.map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;
    try {
      await NotificationService.markAllAsRead(unreadIds);
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
