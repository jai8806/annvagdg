import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/annva_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Shared scaffold wrapping all role dashboards with a bottom nav bar.
/// This is used as the builder for ShellRoute to keep the nav bar persistent.
class AnnvaScaffold extends ConsumerWidget {
  final Widget child;

  const AnnvaScaffold({super.key, required this.child});

  // ─── Nav configs per role ─────────────────────────────────────────────────

  List<_NavItem> _getNavItems(String role) {
    switch (role) {
      case 'seller':
        return const [
          _NavItem(
            Icons.dashboard_outlined,
            Icons.dashboard,
            'Dashboard',
            '/seller',
          ),
          _NavItem(
            Icons.add_circle_outline,
            Icons.add_circle,
            'List Item',
            '/seller',
          ),
          _NavItem(
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            'Impact',
            '/impact',
          ),
          _NavItem(Icons.person_outline, Icons.person, 'Profile', '/profile'),
        ];
      case 'volunteer':
        return const [
          _NavItem(Icons.map_outlined, Icons.map, 'Rescues', '/volunteer'),
          _NavItem(
            Icons.emoji_events_outlined,
            Icons.emoji_events,
            'Missions',
            '/volunteer/missions',
          ),
          _NavItem(
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            'Impact',
            '/impact',
          ),
          _NavItem(Icons.person_outline, Icons.person, 'Profile', '/profile'),
        ];
      case 'ngo':
        return const [
          _NavItem(
            Icons.notifications_outlined,
            Icons.notifications,
            'Incoming',
            '/ngo',
          ),
          _NavItem(
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            'Impact',
            '/impact',
          ),
          _NavItem(Icons.person_outline, Icons.person, 'Profile', '/profile'),
        ];
      default: // consumer
        return const [
          _NavItem(Icons.home_outlined, Icons.home, 'Home', '/consumer'),
          _NavItem(Icons.map_outlined, Icons.map, 'Map', '/consumer/map'),
          _NavItem(
            Icons.receipt_long_outlined,
            Icons.receipt_long,
            'Orders',
            '/consumer/orders',
          ),
          _NavItem(
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            'Impact',
            '/impact',
          ),
          _NavItem(Icons.person_outline, Icons.person, 'Profile', '/profile'),
        ];
    }
  }

  int _currentIndex(BuildContext context, List<_NavItem> items) {
    final loc = GoRouterState.of(context).matchedLocation;

    // Profile and Impact are shared sub-routes
    if (loc.startsWith('/profile')) return items.length - 1;
    final impactIdx = items.indexWhere((i) => i.route == '/impact');
    if (loc.startsWith('/impact') && impactIdx != -1) return impactIdx;

    // Specific match
    for (int i = 0; i < items.length; i++) {
      if (loc == items[i].route) return i;
    }

    // Prefix match
    for (int i = 0; i < items.length; i++) {
      if (loc.startsWith(items[i].route) && items[i].route != '/') return i;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final role = authState.role ?? 'consumer';
    final items = _getNavItems(role);
    final currentIndex = _currentIndex(context, items);

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AnnvaColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AnnvaColors.backgroundCard,
          selectedItemColor: AnnvaColors.primary,
          unselectedItemColor: AnnvaColors.muted,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          onTap: (index) {
            final route = items[index].route;
            // index 0 is the home tab for the role
            if (index == 0) {
              context.go(route);
            } else {
              context.push(route);
            }
          },
          items: items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isActive = idx == currentIndex;
            return BottomNavigationBarItem(
              icon: Icon(isActive ? item.activeIcon : item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.activeIcon, this.label, this.route);
}
