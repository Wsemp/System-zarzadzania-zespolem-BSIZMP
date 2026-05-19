class ApiEndpoints {
  static const String baseUrl =
      'https://system-zarzadzania-zespolem-bsizmp.onrender.com';

  // Auth – serwer używa /api/auth/login/ (nie /api/token/)
  static const String authLogin = '/api/auth/login/';
  static const String token = '/api/token/';
  static const String tokenRefresh = '/api/token/refresh/';
  static const String register = '/api/auth/register/';

  static const String users = '/api/users/';
  static String user(int id) => '/api/users/$id/';

  static const String projects = '/api/projects/';
  static String project(int id) => '/api/projects/$id/';

  static const String tasks = '/api/tasks/';
  static String task(int id) => '/api/tasks/$id/';
}
