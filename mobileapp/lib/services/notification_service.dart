import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    final data = await ApiClient.get(ApiEndpoints.notifications);
    return (data as List).map((j) => NotificationModel.fromJson(j)).toList();
  }

  static Future<void> markAsRead(int id) async {
    // Próbuj PATCH; niektóre backendy używają POST /mark-read/
    try {
      await ApiClient.patch(ApiEndpoints.notification(id), {'is_read': true});
    } catch (_) {
      await ApiClient.post('${ApiEndpoints.notification(id)}mark-read/', {});
    }
  }

  static Future<void> markAllAsRead(List<int> ids) async {
    await Future.wait(ids.map(markAsRead));
  }
}
