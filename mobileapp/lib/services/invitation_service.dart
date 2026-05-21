import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/auth/token_storage.dart';
import '../models/invitation_model.dart';

class InvitationService {
  static Future<List<InvitationModel>> getInvitations() async {
    final data = await ApiClient.get(ApiEndpoints.invitations);
    return (data as List).map((j) => InvitationModel.fromJson(j)).toList();
  }

  static Future<void> sendInvitation({
    required int projectId,
    required int inviteeId,
  }) async {
    final userData = await ApiClient.get(ApiEndpoints.user(inviteeId));
    final email = userData['email'] as String? ?? '';
    final currentUserId = await TokenStorage.getUserId();

    final body = <String, dynamic>{
      'project': ApiEndpoints.projectUrl(projectId),
      'email': email,
    };
    if (currentUserId != null) {
      body['inviter'] = ApiEndpoints.userUrl(currentUserId);
    }

    debugPrint('[INV] sendInvitation project=$projectId email=$email');
    await ApiClient.post(ApiEndpoints.invitations, body);
  }

  static Future<void> acceptInvitation(int id) async {
    debugPrint('[INV] acceptInvitation id=$id');
    await ApiClient.post(ApiEndpoints.invitationAccept(id), {});
  }

  static Future<void> rejectInvitation(int id) async {
    debugPrint('[INV] rejectInvitation id=$id');
    await ApiClient.post(ApiEndpoints.invitationReject(id), {});
  }
}
