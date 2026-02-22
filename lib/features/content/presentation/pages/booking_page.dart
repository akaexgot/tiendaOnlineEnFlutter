import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/mosaic_background.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final String viewId = 'setmore-booking-iframe';

  @override
  void initState() {
    super.initState();
    // Register the iframe view for Flutter Web
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = 'https://slccuts.setmore.com/'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reserva tu cita'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MosaicBackground(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.primary.withOpacity(0.8)
                : Colors.white.withOpacity(0.85),
          ),
          child: HtmlElementView(viewType: viewId),
        ),
      ),
    );
  }
}
