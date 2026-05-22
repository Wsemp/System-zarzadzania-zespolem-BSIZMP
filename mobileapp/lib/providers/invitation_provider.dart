import 'package:flutter/foundation.dart';
import '../models/invitation_model.dart';
import '../services/invitation_service.dart';

class InvitationProvider extends ChangeNotifier {
  List<InvitationModel> _invitations = [];
  bool _loading = false;
  String? _error;

  /// Wszystkie zaproszenia z backendu
  List<InvitationModel> get invitations => _invitations;

  /// Tylko oczekujące (accepted=false) — filtrowane po stronie frontendu
  List<InvitationModel> get pending =>
      _invitations.where((i) => i.isPending).toList();

  bool get loading => _loading;
  String? get error => _error;

  /// Liczba oczekujących zaproszeń — tylko pending, bez accepted
  int get pendingCount => pending.length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _invitations = await InvitationService.getInvitations();
      debugPrint(
        '[INV_PROVIDER] Załadowano ${_invitations.length} zaproszeń, '
        'oczekujących: $pendingCount',
      );
    } catch (e) {
      _error = _friendlyError(e.toString());
      debugPrint('[INV_PROVIDER] Błąd ładowania: $_error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Akceptuje zaproszenie.
  /// Zwraca id projektu przy sukcesie (lub -1 jeśli sukces bez project_id),
  /// null przy błędzie.
  Future<int?> accept(int id) async {
    _error = null;
    try {
      final projectId = await InvitationService.acceptInvitation(id);
      _invitations = _invitations.where((i) => i.id != id).toList();
      notifyListeners();
      debugPrint(
        '[INV_PROVIDER] Zaakceptowano zaproszenie $id, '
        'projekt: ${projectId ?? "brak id w response"}',
      );
      return projectId ?? -1;
    } catch (e) {
      _error = _friendlyError(e.toString());
      debugPrint('[INV_PROVIDER] Błąd akceptacji zaproszenia $id: $_error');
      notifyListeners();
      return null;
    }
  }

  /// Odrzuca zaproszenie. Zwraca true przy sukcesie.
  Future<bool> reject(int id) async {
    _error = null;
    try {
      await InvitationService.rejectInvitation(id);
      _invitations = _invitations.where((i) => i.id != id).toList();
      notifyListeners();
      debugPrint('[INV_PROVIDER] Odrzucono zaproszenie $id');
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      debugPrint('[INV_PROVIDER] Błąd odrzucenia zaproszenia $id: $_error');
      notifyListeners();
      return false;
    }
  }

  static String _friendlyError(String raw) {
    if (raw.contains('401') ||
        raw.contains('Unauthorized') ||
        raw.contains('Sesja wygasła')) {
      return 'Sesja wygasła. Zaloguj się ponownie.';
    }
    if (raw.contains('403') || raw.contains('Forbidden')) {
      return 'Nie masz uprawnień do tego zaproszenia.';
    }
    if (raw.contains('404') || raw.contains('Not found')) {
      return 'Zaproszenie nie istnieje albo wygasło.';
    }
    if (raw.contains('400')) {
      final msg = raw.replaceFirst('Exception: ', '');
      return msg.isNotEmpty ? msg : 'Nieprawidłowe dane. Spróbuj ponownie.';
    }
    if (raw.contains('500')) {
      return 'Nie udało się wykonać akcji. Spróbuj ponownie.';
    }
    if (raw.contains('SocketException') || raw.contains('NetworkException')) {
      return 'Brak połączenia z internetem.';
    }
    final msg = raw.replaceFirst('Exception: ', '');
    return msg.isNotEmpty ? msg : 'Wystąpił błąd. Spróbuj ponownie.';
  }
}
