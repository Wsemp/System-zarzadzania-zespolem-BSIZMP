class ApiEndpoints {
  static const String baseUrl =
      'https://system-zarzadzania-zespolem-bsizmp.onrender.com';

  // Auth
  static const String authLogin = '/api/auth/login/';
  static const String token = '/api/token/';
  static const String tokenRefresh = '/api/token/refresh/';
  static const String register = '/api/auth/register/';
  static const String changePassword = '/api/auth/change-password/';

  // Users
  static const String users = '/api/users/';
  static String user(int id) => '/api/users/$id/';

  // Projects
  static const String projects = '/api/projects/';
  static String project(int id) => '/api/projects/$id/';

  // Tasks
  static const String tasks = '/api/tasks/';
  static String task(int id) => '/api/tasks/$id/';

  // Invitations
  static const String invitations = '/api/invitations/';
  static String invitation(int id) => '/api/invitations/$id/';
  static String invitationAccept(int id) => '/api/invitations/$id/accept/';
  static String invitationReject(int id) => '/api/invitations/$id/reject/';

  // Notifications
  static const String notifications = '/api/notifications/';
  static String notification(int id) => '/api/notifications/$id/';

  // ──────────────────────────────────────────────────────────────────────────
  // URL helpers – backend używa HyperlinkedModelSerializer,
  // więc relacje muszą być wysyłane jako pełne URL-e, nie integer ID
  // ──────────────────────────────────────────────────────────────────────────
  static String userUrl(int id) => '$baseUrl${user(id)}';
  static String projectUrl(int id) => '$baseUrl${project(id)}';
  static String taskUrl(int id) => '$baseUrl${task(id)}';
}
