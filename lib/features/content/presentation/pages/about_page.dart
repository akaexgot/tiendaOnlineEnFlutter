import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tienda Flutter',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Somos una tienda online dedicada a ofrecer los mejores productos con la mejor experiencia de usuario. Desarrollada con Flutter y Supabase para garantizar rendimiento y seguridad.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(
              context,
              icon: Icons.check_circle_outline,
              title: 'Calidad Garantizada',
              description: 'Seleccionamos cuidadosamente cada producto de nuestro catálogo.',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Envío Rápido',
              description: 'Entregas en 24/48 horas en toda la península.',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              icon: Icons.shield_outlined,
              title: 'Compra Segura',
              description: 'Tus datos y pagos están protegidos con la última tecnología.',
            ),
            const SizedBox(height: 48),
            const Text(
              '© 2026 Tienda Flutter. Todos los derechos reservados.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
