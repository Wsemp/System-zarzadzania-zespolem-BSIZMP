import 'package:flutter/foundation.dart';
import '../models/invitation_model.dart';
import '../services/invitation_service.dart';

class InvitationProvider extends ChangeNotifier {
  List<InvitationModel> _invitations = [];
  bool _loading = false;
  String? _error;

  List<InvitationModel> get invitations => _invitations;
  List<InvitationModel> get pending =>
      _invitations.where((i) => i.isPending).toList();
  bool get loading => _loading;
  String? get error => _error;
  int get pendingCount => pending.length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _invitations = await InvitationService.getInvitations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> accept(int id) async {
    try {
      await InvitationService.acceptInvitation(id);
      final idx = _invitations.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _invitations = List.from(_invitations)..removeAt(idx);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(int id) async {
    try {
      await InvitationService.rejectInvitation(id);
      final idx = _invitations.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _invitations = List.from(_invitations)..removeAt(idx);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
