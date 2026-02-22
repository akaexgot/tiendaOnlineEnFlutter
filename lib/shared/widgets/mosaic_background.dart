import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class MosaicBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double logoSize;

  const MosaicBackground({
    super.key,
    required this.child,
    this.opacity = 0.03,
    this.logoSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final logoPath = isDark ? 'assets/images/logo_white.png' : 'assets/images/logo.png';

    return Stack(
      children: [
        // 1. Solid base
        Container(color: bgColor),

        // 2. Artistic Multi-layered Mosaic
        ...List.generate(3, (layerIndex) {
          final layerOpacity = [0.06, 0.04, 0.02][layerIndex];
          final layerSize = [logoSize, logoSize * 1.5, logoSize * 0.8][layerIndex];
          final layerRotation = [-0.2, 0.3, -0.5][layerIndex];
          final staggerX = [0.0, 40.0, -20.0][layerIndex];
          final staggerY = [0.0, 10.0, 50.0][layerIndex]; // Fixed: Removed negative value

          return Positioned.fill(
            child: Opacity(
              opacity: layerOpacity,
              child: GridView.builder(
                padding: EdgeInsets.only(left: staggerX, top: staggerY),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 40,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: layerSize,
                  childAspectRatio: 1,
                  crossAxisSpacing: 60,
                  mainAxisSpacing: 60,
                ),
                itemBuilder: (context, index) {
                  // Add some randomness based on index
                  final isVisible = (index * (layerIndex + 1)) % 7 != 0;
                  if (!isVisible) return const SizedBox.shrink();

                  return Transform.rotate(
                    angle: layerRotation,
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          );
        }),

        // 3. Radial Vignette for focus
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  bgColor.withOpacity(0.35),
                  bgColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        // 4. Subtle Noise/Grain Effect - REMOVED due to network errors
        // const Positioned.fill(...)

        // 5. Vertical linear gradient for depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor.withOpacity(0.6),
                  Colors.transparent,
                  bgColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),

        // 6. Main content
        child,
      ],
    );
  }
}
