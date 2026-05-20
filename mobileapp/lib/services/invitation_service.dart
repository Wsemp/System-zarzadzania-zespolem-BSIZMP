import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
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
    await ApiClient.post(ApiEndpoints.invitations, {
      'project': ApiEndpoints.projectUrl(projectId),
      'invitee': ApiEndpoints.userUrl(inviteeId),
    });
  }

  static Future<void> acceptInvitation(int id) async {
    try {
      await ApiClient.post(ApiEndpoints.invitationAccept(id), {});
    } catch (_) {
      await ApiClient.patch(ApiEndpoints.invitation(id), {
        'status': 'accepted',
      });
    }
  }

  static Future<void> rejectInvitation(int id) async {
    try {
      await ApiClient.post(ApiEndpoints.invitationReject(id), {});
    } catch (_) {
      await ApiClient.patch(ApiEndpoints.invitation(id), {
        'status': 'rejected',
      });
    }
  }
}
