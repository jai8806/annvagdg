import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../../../shared/widgets/certification_widgets.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
        children: [
          const SizedBox(height: AnnvaSpacing.lg),

          // Header Info
          Row(
            children: [
              Container(
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
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Karthik N', style: AnnvaTextStyles.h2),
                    const Text(
                      'Bengaluru, Karnataka',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Verified ${role.substring(0, 1).toUpperCase()}${role.substring(1)}',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('64', style: AnnvaTextStyles.h1.copyWith(fontSize: 32)),
                  const Text(
                    'Total Rescues',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stats Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AnnvaColors.border, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStat('25', 'Service Hours'),
                _buildProfileStat('320', 'Meals Delivered'),
                _buildProfileStat('18 kg', 'Food Rescued'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // My Impact Credentials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MY IMPACT CREDENTIALS',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
              Text(
                'View all →',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CredentialItem(
            title: 'Gold Volunteer - Bengaluru Chapter',
            date: 'April 2024',
            description: 'Awarded for outstanding dedication and consistent food rescue efforts.',
            icon: Icons.workspace_premium,
            color: Colors.amber,
          ),
          const CredentialItem(
            title: 'Community Service Certificate',
            date: 'April 2024',
            description: 'Completed 25 hours of service through ANNVA platform.',
            icon: Icons.verified,
            color: Colors.blueGrey,
          ),
          const CredentialItem(
            title: 'Sustainability Champion',
            date: 'April 2024',
            description: 'Thank you for helping reduce food waste and carbon footprint.',
            icon: Icons.eco,
            color: AnnvaColors.cascadeFresh,
          ),

          const SizedBox(height: 32),
          const Divider(color: AnnvaColors.border),
          const SizedBox(height: AnnvaSpacing.lg),

          // Actions
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_role');
                ref.read(authNotifierProvider.notifier).clearRole();
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AnnvaColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 10,
            color: AnnvaColors.muted,
          ),
        ),
      ],
    );
  }
}
