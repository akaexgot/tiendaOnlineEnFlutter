import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scaffoldMessengerProvider = Provider((ref) => ScaffoldMessengerService());

class ScaffoldMessengerService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSnackBar(String message, {SnackBarType type = SnackBarType.info}) {
    final state = scaffoldMessengerKey.currentState;
    if (state != null) {
      Color backgroundColor;
      switch (type) {
        case SnackBarType.success:
          backgroundColor = Colors.green;
          break;
        case SnackBarType.error:
          backgroundColor = Colors.red;
          break;
        case SnackBarType.info:
        default:
          backgroundColor = Colors.blue;
          break;
      }

      state.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

enum SnackBarType { success, error, info }
