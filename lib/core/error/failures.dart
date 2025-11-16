import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Failures represent errors that occur in the domain/data layer
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Server-related failures (API errors)
class ServerFailure extends Failure {
  final int? code;

  const ServerFailure({
    required String message,
    this.code,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code];
}

/// Cache-related failures (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Validation failures (invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

/// General/unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message: message);
}
