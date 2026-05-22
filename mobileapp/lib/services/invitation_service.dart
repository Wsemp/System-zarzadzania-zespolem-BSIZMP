import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/auth/token_storage.dart';
import '../models/invitation_model.dart';

class InvitationService {
  /// GET /api/invitations/
  /// Backend zwraca zaproszenia skierowane na email zalogowanego użytkownika.
  /// Filtrowanie do pending wykonywane jest po stronie frontendu.
  static Future<List<InvitationModel>> getInvitations() async {
    debugPrint('[INV] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.invitations}');
    final data = await ApiClient.get(ApiEndpoints.invitations);
    final list = (data as List)
        .map((j) => InvitationModel.fromJson(j as Map<String, dynamic>))
        .toList();
    debugPrint('[INV] Pobrano ${list.length} zaproszeń łącznie');
    return list;
  }

  /// POST /api/invitations/  — wysyła zaproszenie do projektu
  static Future<void> sendInvitation({
    required int projectId,
    required int inviteeId,
  }) async {
    final userData = await ApiClient.get(ApiEndpoints.user(inviteeId));
    final email = userData['email'] as String? ?? '';
    final currentUserId = await TokenStorage.getUserId();

    final body = <String, dynamic>{'project': projectId, 'email': email};
    if (currentUserId != null) {
      body['inviter'] = currentUserId;
    }

    debugPrint('[INV] sendInvitation project=$projectId email=$email');
    await ApiClient.post(ApiEndpoints.invitations, body);
  }

  /// POST /api/invitations/{id}/accept/
  /// Backend zwraca pełny obiekt zaproszenia (serializer.data) z HTTP 200.
  /// Próbujemy wyciągnąć project id z response.
  static Future<int?> acceptInvitation(int id) async {
    debugPrint(
      '[INV] acceptInvitation id=$id → POST ${ApiEndpoints.invitationAccept(id)}',
    );
    final response = await ApiClient.post(
      ApiEndpoints.invitationAccept(id),
      {},
    );
    debugPrint('[INV] acceptInvitation response: $response');
    if (response is Map) {
      final projectRaw = response['project'];
      int? projectId;
      if (projectRaw is int) {
        projectId = projectRaw;
      } else if (projectRaw is String) {
        final parts = projectRaw.split('/').where((s) => s.isNotEmpty).toList();
        projectId = parts.isNotEmpty ? int.tryParse(parts.last) : null;
      }
      debugPrint('[INV] acceptInvitation projectId=$projectId');
      return projectId;
    }
    return null;
  }

  /// POST /api/invitations/{id}/reject/
  /// Backend zwraca HTTP 204 bez body — sukces gdy brak wyjątku.
  static Future<void> rejectInvitation(int id) async {
    debugPrint(
      '[INV] rejectInvitation id=$id → POST ${ApiEndpoints.invitationReject(id)}',
    );
    await ApiClient.post(ApiEndpoints.invitationReject(id), {});
    debugPrint('[INV] rejectInvitation id=$id OK');
  }
}
