import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class UserService {
  static Future<List<UserModel>> getUsers() async {
    final data = await ApiClient.get(ApiEndpoints.users);
    return (data as List).map((j) => UserModel.fromJson(j)).toList();
  }

  static Future<UserModel> getUser(int id) async {
    final data = await ApiClient.get(ApiEndpoints.user(id));
    return UserModel.fromJson(data);
  }

  static Future<UserModel> updateUser(
    int id, {
    String? username,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    final data = await ApiClient.patch(ApiEndpoints.user(id), body);
    return UserModel.fromJson(data);
  }
}
