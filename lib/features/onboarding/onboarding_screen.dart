import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/annva_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _titles = [
    'The problem is real →',
    'See how it works →',
    'Get started →',
  ];

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
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AnnvaColors.primary,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: const [
                      _ProblemPage(),
                      _SolutionPage(),
                      _RolesPage(),
                    ],
                  ),
                  Positioned(
                    top: 56,
                    right: 16,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 12,
                          color: AnnvaColors.primaryForeground.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: AnnvaColors.primaryForeground.withValues(alpha: 0.04),
                border: Border(
                  top: BorderSide(
                    color: AnnvaColors.primaryForeground.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AnnvaColors.ochre.withValues(
                            alpha: isActive ? 1 : 0.3,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _currentPage == 2
                            ? AnnvaColors.ochre
                            : AnnvaColors.primary,
                        foregroundColor: _currentPage == 2
                            ? AnnvaColors.ochreForeground
                            : AnnvaColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage == 2) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Text(
                        _titles[_currentPage],
                        style: const TextStyle(
                          fontFamily: 'WorkSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemPage extends StatelessWidget {
  const _ProblemPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍲', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '78 million tonnes\nwasted every year.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 22,
                height: 1.3,
                color: AnnvaColors.primaryForeground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'While 194 million Indians\ngo hungry every night.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 13,
                height: 1.5,
                color: AnnvaColors.primaryForeground.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionPage extends StatelessWidget {
  const _SolutionPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AnnvaColors.primaryForeground.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: const [
                  _CascadeRow(
                    background: Color(0x402E7D52),
                    title: 'Bisi bele bath',
                    chipLabel: 'Fresh — 20% off',
                    chipColor: AnnvaColors.cascadeFresh,
                  ),
                  _CascadeRow(
                    background: Color(0x33E09A1C),
                    title: 'Butter croissants',
                    chipLabel: 'Hot deal — 60% off',
                    chipColor: AnnvaColors.ochre,
                  ),
                  _CascadeRow(
                    background: Color(0x33D63B1A),
                    title: 'Wedding biryani',
                    chipLabel: 'Final hour — Free',
                    chipColor: AnnvaColors.cascadeUrgent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The price drops\nas the clock ticks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 21,
                color: AnnvaColors.primaryForeground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Powered by food safety science,\nnot arbitrary expiry labels.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12,
                color: AnnvaColors.primaryForeground.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CascadeRow extends StatelessWidget {
  const _CascadeRow({
    required this.background,
    required this.title,
    required this.chipLabel,
    required this.chipColor,
  });

  final Color background;
  final String title;
  final String chipLabel;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: background),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 11,
                color: AnnvaColors.primaryForeground,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              chipLabel,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: chipColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolesPage extends StatelessWidget {
  const _RolesPage();

  static const _roles = [
    ('🛒', 'Consumer', 'Rescue deals near you'),
    ('🍽', 'Seller', 'List surplus in 60s'),
    ('🤝', 'Volunteer', 'Deliver, earn certs'),
    ('🏠', 'NGO', 'Receive free food'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _roles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AnnvaColors.primaryForeground.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AnnvaColors.primaryForeground.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        role.$2,
                        style: const TextStyle(
                          fontFamily: 'WorkSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: AnnvaColors.primaryForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.$3,
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 9,
                          color: AnnvaColors.primaryForeground.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'One platform.\nFour ways to help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 21,
                color: AnnvaColors.primaryForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'अन्न ही ब्रह्म है · Food is sacred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSerifDevanagari',
                fontSize: 11,
                color: AnnvaColors.primaryForeground.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
