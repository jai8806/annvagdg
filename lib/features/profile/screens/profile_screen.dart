import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/annva_logo.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final role = authState.role ?? 'consumer';
    final phone = authState.phoneNumber ?? '—';

    final roleColors = {
      'consumer': AnnvaColors.primary,
      'seller': AnnvaColors.ochre,
      'volunteer': AnnvaColors.cascadeFresh,
      'ngo': AnnvaColors.primary,
    };
    final roleColor = roleColors[role] ?? AnnvaColors.primary;

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AnnvaColors.primary,
                  size: 18,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: const AnnvaLogo(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AnnvaSpacing.lg),

            // Avatar
                  Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  role.substring(0, 1).toUpperCase(),
                  style: AnnvaTextStyles.h1.copyWith(
                    color: roleColor,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AnnvaSpacing.md),

            // Phone
            Center(child: Text(phone, style: AnnvaTextStyles.h2)),
            const SizedBox(height: 8),

            // Role chip
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AnnvaRadius.full),
                  border: Border.all(color: roleColor),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AnnvaSpacing.xxl),
            const Divider(color: AnnvaColors.border),
            const SizedBox(height: AnnvaSpacing.lg),

            // Switch role
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  // Clear only the role from prefs, keep phone number
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('auth_role');
                  // Update auth state — authenticated but no role
                  ref.read(authNotifierProvider.notifier).clearRole();
                  // GoRouter redirect will see: authenticated + role == null
                  // and automatically push to /auth/role
                  if (context.mounted) context.push('/auth/role');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AnnvaColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AnnvaRadius.full),
                  ),
                ),
                child: const Text(
                  'Switch role →',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AnnvaSpacing.md),

            // Sign out
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnnvaColors.cascadeUrgent.withValues(alpha: 0.08),
                  foregroundColor: AnnvaColors.cascadeUrgent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AnnvaRadius.full),
                  ),
                ),
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
