import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/invitation_model.dart';

class InvitationService {
  static Future<List<InvitationModel>> getInvitations() async {
    final data = await ApiClient.get(ApiEndpoints.invitations);
    return (data as List).map((j) => InvitationModel.fromJson(j)).toList();
  }

  static Future<void> acceptInvitation(int id) async {
    // Próbuj dedykowanego endpointu; jeśli backend go nie ma,
    // użyj PATCH ze statusem
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
