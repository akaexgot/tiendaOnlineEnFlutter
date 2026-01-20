/// Clase base para excepciones personalizadas
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => message;
}

/// Excepción para errores de servidor
class ServerException extends AppException {
  ServerException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción para errores de conexión
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción para datos no encontrados
class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Clase para representar fallos
class Failure {
  final String message;
  final String? code;
  
  Failure({
    required this.message,
    this.code,
  });
  
  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      code: exception.code,
    );
  }
  
  @override
  String toString() => message;
}
