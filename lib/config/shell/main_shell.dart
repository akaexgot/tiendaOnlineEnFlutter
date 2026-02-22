import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

import '../../shared/widgets/mosaic_background.dart';
import '../../shared/widgets/glass_container.dart';

/// Main shell with bottom navigation
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      body: MosaicBackground(child: widget.child),
      bottomNavigationBar: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        blur: 15,
        opacity: 0.1,
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.primary 
            : Colors.white,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        border: Border(
          top: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05), width: 1.5),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            _onItemTapped(context, index, isAdmin);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 65,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Productos',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Reservas',
            ),
            NavigationDestination(
              icon: _buildCartBadge(cartItemCount, false),
              selectedIcon: _buildCartBadge(cartItemCount, true),
              label: 'Carrito',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
            if (isAdmin)
              const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBadge(int count, bool isSelected) {
    return badges.Badge(
      showBadge: count > 0,
      badgeContent: Text(
        count.toString(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: isSelected ? AppColors.accentLight : AppColors.accent,
        padding: const EdgeInsets.all(4),
      ),
      child: Icon(
        isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        color: isSelected ? AppColors.accent : null,
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index, bool isAdmin) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.products);
        break;
      case 2:
        context.go(AppRoutes.booking);
        break;
      case 3:
        context.go(AppRoutes.cart);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
      case 5:
        if (isAdmin) context.go(AppRoutes.admin);
        break;
    }
  }
}
