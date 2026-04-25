import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/screens/phone_entry_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/consumer/screens/consumer_home_screen.dart';
import '../../features/consumer/screens/listing_detail_screen.dart';
import '../../features/consumer/screens/consumer_map_screen.dart';
import '../../features/consumer/screens/cart_screen.dart';
import '../../features/seller/screens/seller_home_screen.dart';
import '../../features/volunteer/screens/volunteer_home_screen.dart';
import '../../features/ngo/screens/ngo_home_screen.dart';
import '../../features/impact/screens/impact_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/demo/demo_screen.dart';
import '../../shared/widgets/annva_scaffold.dart';

part 'app_router.g.dart';

// We keep these keys as static constants to ensure they never change
// during a provider rebuild, which prevents GlobalKey duplicate errors.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      
      // CRITICAL: while loading prefs, don't redirect anywhere
      if (authState.isLoading) return null;
      
      final isAuthenticated = authState.isAuthenticated;
      final role = authState.role;
      final loc = state.matchedLocation;
      
      final isAuthRoute = loc.startsWith('/auth');
      final isDemoRoute = loc == '/';
      final isPublicRoute = isAuthRoute || isDemoRoute;
      
      // Not authenticated: only allow '/' and '/auth/*'
      if (!isAuthenticated && !isPublicRoute) {
        return '/';
      }

      // Authenticated but no role yet: send to role selection
      if (isAuthenticated && role == null && !isAuthRoute) {
        return '/auth/role';
      }
      
      // Authenticated but on auth route: go to role home
      if (isAuthenticated && role != null && isAuthRoute) {
        return _roleHome(role);
      }
      
      // Authenticated on demo: go to role home
      if (isAuthenticated && role != null && isDemoRoute) {
        return _roleHome(role);
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DemoScreen(key: ValueKey('demo_screen')), // Landing
      ),
      GoRoute(
        path: '/demo',
        builder: (context, state) => const DemoScreen(key: ValueKey('demo_screen_alt')),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const PhoneEntryScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) => const OtpVerifyScreen(),
          ),
          GoRoute(
            path: 'role',
            builder: (context, state) => const RoleSelectScreen(),
          ),
        ],
      ),
      
      // Authenticated area with Bottom Nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AnnvaScaffold(child: child),
        routes: [
          // Consumer
          GoRoute(
            path: '/consumer',
            builder: (context, state) => const ConsumerHomeScreen(key: ValueKey('consumer_home')),
            routes: [
              GoRoute(
                path: 'map',
                builder: (context, state) => const ConsumerMapScreen(key: ValueKey('consumer_map')),
              ),
              GoRoute(
                path: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: 'listing/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ListingDetailScreen(listingId: id);
                },
              ),
            ],
          ),
          // Seller
          GoRoute(
            path: '/seller',
            builder: (context, state) => const SellerHomeScreen(key: ValueKey('seller_home')),
          ),
          // Volunteer
          GoRoute(
            path: '/volunteer',
            builder: (context, state) => const VolunteerHomeScreen(key: ValueKey('volunteer_home')),
            routes: [
              GoRoute(
                path: 'missions',
                builder: (context, state) => const Scaffold(body: Center(child: Text('Missions Screen'))),
              ),
            ],
          ),
          // NGO
          GoRoute(
            path: '/ngo',
            builder: (context, state) => const NgoHomeScreen(key: ValueKey('ngo_home')),
          ),
          // Impact (Shared)
          GoRoute(
            path: '/impact',
            builder: (context, state) => const ImpactScreen(key: ValueKey('impact_screen')),
          ),
          // Profile (Shared)
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(key: ValueKey('profile_screen')),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() => router.dispose());

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    router.refresh();
  });

  return router;
}

String _roleHome(String? role) {
  switch (role) {
    case 'seller': return '/seller';
    case 'volunteer': return '/volunteer';
    case 'ngo': return '/ngo';
    default: return '/consumer';
  }
}
