import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../providers/auth_provider.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final selectedRole = authState.pendingRole;

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AnnvaSpacing.xl),
              const Text(
                'I am a...',
                style: TextStyle(
                  fontFamily: 'InstrumentSerif',
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  color: AnnvaColors.primary,
                ),
              ),
              const SizedBox(height: AnnvaSpacing.xxl),

              // Grid of roles
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AnnvaSpacing.md,
                  crossAxisSpacing: AnnvaSpacing.md,
                  childAspectRatio: 0.9,
                  children: [
                    _RoleCard(
                      role: 'consumer',
                      title: 'Consumer',
                      description: '🛒 I want to rescue food deals',
                      isSelected: selectedRole == 'consumer',
                      onTap: () => ref
                          .read(authNotifierProvider.notifier)
                          .setPendingRole('consumer'),
                    ),
                    _RoleCard(
                      role: 'seller',
                      title: 'Seller',
                      description: '🍽 I have surplus food to list',
                      isSelected: selectedRole == 'seller',
                      onTap: () => ref
                          .read(authNotifierProvider.notifier)
                          .setPendingRole('seller'),
                    ),
                    _RoleCard(
                      role: 'volunteer',
                      title: 'Volunteer',
                      description: '🤝 I want to deliver rescues',
                      isSelected: selectedRole == 'volunteer',
                      onTap: () => ref
                          .read(authNotifierProvider.notifier)
                          .setPendingRole('volunteer'),
                    ),
                    _RoleCard(
                      role: 'ngo',
                      title: 'NGO',
                      description: '🏠 We receive food donations',
                      isSelected: selectedRole == 'ngo',
                      onTap: () => ref
                          .read(authNotifierProvider.notifier)
                          .setPendingRole('ngo'),
                    ),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () async {
                          // Trigger async signIn, the router will auto-redirect
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signIn(selectedRole);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnnvaColors.primary,
                    foregroundColor: AnnvaColors.primaryForeground,
                    disabledBackgroundColor: AnnvaColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AnnvaRadius.full),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AnnvaSpacing.sm),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AnnvaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: isSelected
            ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isSelected ? AnnvaColors.primary : AnnvaColors.backgroundCard,
          border: Border.all(
            color: isSelected ? AnnvaColors.primary : AnnvaColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        ),
        padding: const EdgeInsets.all(AnnvaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AnnvaColors.primaryForeground
                    : AnnvaColors.primary,
              ),
            ),
            const SizedBox(height: AnnvaSpacing.sm),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 13,
                height: 1.4,
                color: isSelected
                    ? AnnvaColors.primaryForeground.withOpacity(0.8)
                    : AnnvaColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
