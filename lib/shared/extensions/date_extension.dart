/// Extensiones para DateTime
extension DateExtension on DateTime {
  /// Formatea la fecha como "dd/MM/yyyy"
  String toFormattedDate() {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formatea la fecha y hora como "dd/MM/yyyy HH:mm"
  String toFormattedDateTime() {
    return '$day/${month.toString().padLeft(2, '0')}/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Verifica si la fecha es hoy
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si la fecha fue ayer
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}
