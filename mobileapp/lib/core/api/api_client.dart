import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../auth/token_storage.dart';
import '../errors/app_exception.dart';
import 'api_endpoints.dart';

class ApiClient {
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json; charset=utf-8'};
    if (auth) {
      final token = await TokenStorage.getAccess();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<bool> _refreshToken() async {
    final refresh = await TokenStorage.getRefresh();
    if (refresh == null) return false;
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.tokenRefresh}',
      );
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'refresh': refresh}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        await TokenStorage.saveTokens(access: data['access'], refresh: refresh);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<dynamic> get(
    String path, {
    bool auth = true,
    Map<String, String>? queryParams,
  }) {
    final fullPath = queryParams != null && queryParams.isNotEmpty
        ? '$path?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : path;
    return _request('GET', fullPath, auth: auth);
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _request('POST', path, body: body, auth: auth);

  static Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _request('PATCH', path, body: body);

  static Future<void> delete(String path) async => _request('DELETE', path);

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
      final headers = await _headers(auth: auth);
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
        default:
          throw AppException('Nieznana metoda HTTP');
      }

      debugPrint('[API] $method $path → ${response.statusCode}');

      if (response.statusCode >= 500) {
        debugPrint('[API] ❌ SERVER ERROR');
        debugPrint('[API]   URL: ${ApiEndpoints.baseUrl}$path');
        debugPrint('[API]   Method: $method');
        if (body != null) debugPrint('[API]   Body: $body');
        debugPrint('[API]   Status: ${response.statusCode}');
        debugPrint('[API]   Response: ${response.body}');
      }

      if (response.statusCode == 401 && auth) {
        final refreshed = await _refreshToken();
        if (refreshed) return _request(method, path, body: body, auth: auth);
        throw const UnauthorizedException();
      }

      if (response.statusCode == 403) {
        debugPrint('[API] 403 Forbidden: $path');
        throw const ForbiddenException();
      }

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    if (response.statusCode == 400) {
      String msg = 'Błąd walidacji';
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('[API] 400 body: $data');
        if (data is Map && data.isNotEmpty) {
          final sb = StringBuffer();
          data.forEach((key, value) {
            final v = value is List ? value.join(', ') : value.toString();
            sb.write('$key: $v  ');
          });
          msg = sb.toString().trim();
        }
      } catch (_) {}
      throw ValidationException(msg);
    }
    if (response.statusCode == 404) {
      throw const NotFoundException('Nie znaleziono zasobu');
    }
    if (response.statusCode >= 500) {
      debugPrint('[API] 5xx body: ${response.body}');
      throw AppException(
        'Nie udało się wykonać akcji. Spróbuj ponownie.',
        statusCode: response.statusCode,
      );
    }
    debugPrint('[API] Error ${response.statusCode}: ${response.body}');
    throw AppException(
      'Błąd serwera: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
}
