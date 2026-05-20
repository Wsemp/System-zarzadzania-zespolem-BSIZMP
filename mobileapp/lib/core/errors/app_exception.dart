class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super('Sesja wygasła. Zaloguj się ponownie.', statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends AppException {
  const ValidationException(super.message) : super(statusCode: 400);
}

class NetworkException extends AppException {
  const NetworkException() : super('Brak połączenia z internetem.');
}
