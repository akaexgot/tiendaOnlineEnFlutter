/// Extensiones para String
extension StringExtension on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Verifica si es un email válido
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(this);
  }

  /// Verifica si es una contraseña fuerte (mín 8 caracteres, mayúscula, número)
  bool isStrongPassword() {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  /// Elimina espacios en blanco
  String trimAll() => replaceAll(RegExp(r'\s+'), '');
}
