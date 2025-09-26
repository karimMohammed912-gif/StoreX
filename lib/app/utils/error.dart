import 'package:dio/dio.dart';

/// This file defines custom error handling for the application, including various failure types and their handling.
class Failure {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.statusCode});

  factory ServerFailure.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return ServerFailure('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Server response timeout. Please try again.');
      case DioExceptionType.badResponse:
        return ServerFailure.fromStatusCode(error.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return ServerFailure('Request was cancelled.');
      case DioExceptionType.connectionError:
        return ServerFailure(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badCertificate:
        return ServerFailure('Security certificate error.');
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return ServerFailure(
            'No internet connection. Please check your network.',
          );
        }
        return ServerFailure('Something went wrong. Please try again.');
    }
  }

  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      // Client Error Responses (4xx)
      case 400:
        return ServerFailure(
          'Bad request. Please check your input and try again.',
          statusCode: 400,
        );
      case 401:
        return ServerFailure(
          'Unauthorized access. Please check your credentials.',
          statusCode: 401,
        );
      case 403:
        return ServerFailure(
          'Access forbidden. You don\'t have permission to access this resource.',
          statusCode: 403,
        );
      case 404:
        return ServerFailure(
          'Resource not found. The requested data is unavailable.',
          statusCode: 404,
        );
      case 405:
        return ServerFailure(
          'Method not allowed. Invalid request method.',
          statusCode: 405,
        );
      case 408:
        return ServerFailure(
          'Request timeout. Please try again.',
          statusCode: 408,
        );
      case 409:
        return ServerFailure(
          'Conflict. The request conflicts with current state.',
          statusCode: 409,
        );
      case 410:
        return ServerFailure('Resource no longer available.', statusCode: 410);
      case 422:
        return ServerFailure(
          'Invalid data provided. Please check your input.',
          statusCode: 422,
        );
      case 429:
        return ServerFailure(
          'Too many requests. Please wait a moment before trying again.',
          statusCode: 429,
        );

      // Server Error Responses (5xx)
      case 500:
        return ServerFailure(
          'Internal server error. Please try again later.',
          statusCode: 500,
        );
      case 501:
        return ServerFailure(
          'Service not implemented. Feature is not available.',
          statusCode: 501,
        );
      case 502:
        return ServerFailure(
          'Bad gateway. Server is temporarily unavailable.',
          statusCode: 502,
        );
      case 503:
        return ServerFailure(
          'Service unavailable. Server is temporarily down.',
          statusCode: 503,
        );
      case 504:
        return ServerFailure(
          'Gateway timeout. Server took too long to respond.',
          statusCode: 504,
        );
      case 505:
        return ServerFailure('HTTP version not supported.', statusCode: 505);

      // Default cases
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ServerFailure(
            'Client error occurred. Please check your request.',
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return ServerFailure(
            'Server error occurred. Please try again later.',
            statusCode: statusCode,
          );
        } else {
          return ServerFailure(
            'Unknown error occurred. Status code: $statusCode',
            statusCode: statusCode,
          );
        }
    }
  }
}

// Additional specific failure types for better error handling
class NetworkFailure extends Failure {
  NetworkFailure()
    : super('No internet connection. Please check your network.');
}

class CacheFailure extends Failure {
  CacheFailure() : super('Failed to load cached data.');
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

// Extension for better error handling in UI
extension ServerFailureExtension on ServerFailure {
  bool get isRateLimited => statusCode == 429;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  String get userFriendlyMessage {
    if (isRateLimited) {
      return 'Please wait a moment before making another request.';
    } else if (isUnauthorized) {
      return 'Please log in again to continue.';
    } else if (isNotFound) {
      return 'The requested information is not available.';
    } else if (isServerError) {
      return 'Our servers are experiencing issues. Please try again later.';
    } else {
      return message;
    }
  }
}
