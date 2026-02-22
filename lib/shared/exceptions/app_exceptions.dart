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
    required super.message,
    super.code,
  });
}

/// Excepción para errores de conexión
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
  });
}

/// Excepción para datos no encontrados
class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.code,
  });
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
  });
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
