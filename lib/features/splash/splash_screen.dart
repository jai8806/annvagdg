import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/annva_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final ValueChanged<bool> onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _dotsController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  bool _showDots = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _logoOpacity = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _showDots = true);

    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarding_complete') ?? false;
    if (!mounted) return;

    widget.onFinished(onboarded);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnvaColors.primary,
      body: Stack(
        children: [
          Center(
            child: IgnorePointer(
              child: Text(
                'अन्नवा',
                style: TextStyle(
                  fontFamily: 'NotoSerifDevanagari',
                  fontSize: 160,
                  color: AnnvaColors.creamLight.withOpacity(0.1),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(scale: _logoScale.value, child: child),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'अन्नवा',
                        style: TextStyle(
                          fontFamily: 'NotoSerifDevanagari',
                          fontSize: 26,
                          color: AnnvaColors.primaryForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Annva',
                        style: const TextStyle(
                          fontFamily: 'InstrumentSerif',
                          fontSize: 26,
                          fontStyle: FontStyle.italic,
                          color: AnnvaColors.primaryForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 32,
                    height: 1,
                    color: AnnvaColors.ochre.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FOOD THAT MOVES',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: AnnvaColors.creamLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 54),
              child: AnimatedOpacity(
                opacity: _showDots ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final wave =
                          (_dotsController.value + (index * 0.2)) % 1.0;
                      final pulse = 1 - (2 * wave - 1).abs();
                      final scale = 1 + (0.4 * pulse);
                      final opacity = 0.5 + (0.5 * pulse);
                      return Padding(
                        padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AnnvaColors.ochre.withOpacity(opacity),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
