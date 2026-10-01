class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized session expired'})
      : super(message: message, statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException({String message = 'Network connection failure'})
      : super(message: message);
}
