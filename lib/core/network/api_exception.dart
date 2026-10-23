import 'package:equatable/equatable.dart';

abstract class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  List<Object?> get props => [message, statusCode, details];

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Unable to connect to EBS BioCrop servers. Please check your network.',
    super.statusCode,
  });
}

class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode = 500,
    super.details,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied. You do not have permission for this action.',
    super.statusCode = 403,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    required super.message,
    super.statusCode = 400,
    this.errors,
  }) : super(details: errors);

  @override
  List<Object?> get props => [message, statusCode, errors];
}
