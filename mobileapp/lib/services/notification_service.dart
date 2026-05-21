import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    final data = await ApiClient.get(ApiEndpoints.notifications);
    return (data as List).map((j) => NotificationModel.fromJson(j)).toList();
  }

  static Future<void> markAsRead(int id) async {
    await ApiClient.patch(ApiEndpoints.notification(id), {'is_read': true});
  }

  static Future<void> markAllAsRead() async {
    await ApiClient.post('${ApiEndpoints.notifications}mark-all-read/', {});
  }
}
