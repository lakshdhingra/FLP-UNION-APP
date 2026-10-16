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
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized session expired'})
      : super(statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Network connection failure'});
}
