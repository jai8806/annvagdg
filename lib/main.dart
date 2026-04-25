import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/annva_colors.dart';
import 'core/theme/annva_text_styles.dart';
import 'core/theme/annva_theme.dart';
import 'features/auth/providers/auth_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: AnnvaApp()));
}

/// Root app widget. Uses Heritage Indigo theme and GoRouter.
class AnnvaApp extends ConsumerWidget {
  const AnnvaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authNotifierProvider);

    // We wrap everything in MaterialApp.router to avoid GlobalKey conflicts
    // during the transition from a non-router MaterialApp.
    return MaterialApp.router(
      title: 'Annva — अन्नवा',
      debugShowCheckedModeBanner: false,
      theme: AnnvaTheme.light(),
      routerConfig: router,
      // If we are loading, we can show a overlay or handle it in the router
      // But for now, since GoRouter is ready, it will handle its own states.
      // We can also use builder to show loading if needed.
      builder: (context, child) {
        if (authState.isLoading) {
          return Scaffold(
            backgroundColor: AnnvaColors.background,
            body: Center(
              child: Text(
                'अन्न',
                style: AnnvaTextStyles.devanagariWatermark.copyWith(
                  fontSize: 48,
                  color: AnnvaColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }
        return child!;
      },
    );
  }
}
