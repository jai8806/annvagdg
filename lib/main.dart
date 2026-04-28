import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/annva_colors.dart';
import 'core/theme/annva_text_styles.dart';
import 'core/theme/annva_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/splash/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const ProviderScope(child: AnnvaApp()));
}

/// Root app widget. Uses Heritage Indigo theme and GoRouter.
class AnnvaApp extends ConsumerStatefulWidget {
  const AnnvaApp({super.key});

  @override
  ConsumerState<AnnvaApp> createState() => _AnnvaAppState();
}

class _AnnvaAppState extends ConsumerState<AnnvaApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authNotifierProvider);
    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );

    return MaterialApp.router(
      title: 'Annva — अन्नवा',
      debugShowCheckedModeBanner: false,
      theme: AnnvaTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        final content = authState.isLoading
            ? Scaffold(
                backgroundColor: AnnvaColors.background,
                body: Center(
                  child: Text(
                    'अन्नवा',
                    style: AnnvaTextStyles.devanagariWatermark.copyWith(
                      fontSize: 48,
                      color: AnnvaColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            : child ?? const SizedBox.shrink();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _showSplash
                ? SplashScreen(
                    key: const ValueKey('splash'),
                    onFinished: (onboarded) {
                      router.go(onboarded ? '/' : '/onboarding');
                      if (!mounted) return;
                      // Small delay to let router initialize the new page
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) setState(() => _showSplash = false);
                      });
                    },
                  )
                : content, // content already contains the current route via router
          ),
        );
      },
    );
  }
}
