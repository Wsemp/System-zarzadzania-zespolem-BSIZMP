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
      _error = _friendlyError(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> accept(int id) async {
    try {
      await InvitationService.acceptInvitation(id);
      _invitations = _invitations.where((i) => i.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(int id) async {
    try {
      await InvitationService.rejectInvitation(id);
      _invitations = _invitations.where((i) => i.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    }
  }

  static String _friendlyError(String raw) {
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return 'Sesja wygasła. Zaloguj się ponownie.';
    }
    if (raw.contains('400')) {
      return 'Nieprawidłowe dane. Spróbuj ponownie.';
    }
    if (raw.contains('500')) {
      return 'Błąd serwera. Skontaktuj się z administratorem.';
    }
    if (raw.contains('SocketException') || raw.contains('NetworkException')) {
      return 'Brak połączenia z internetem.';
    }
    final msg = raw.replaceFirst('Exception: ', '');
    return msg.isNotEmpty ? msg : 'Wystąpił błąd. Spróbuj ponownie.';
  }
}
