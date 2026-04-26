import 'package:flutter/material.dart';

import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';

/// Demo mode role switcher pill.
///
/// Visual spec (Section 6.7):
/// ```
/// [ Demo as: | Consumer | Seller | Volunteer | NGO ]
/// ```
/// - Pill container, rounded-full
/// - Active role: primary background, primaryForeground text
/// - Inactive: transparent, muted text
enum DemoRole { consumer, seller, volunteer, ngo }

extension DemoRoleLabel on DemoRole {
  String get label {
    switch (this) {
      case DemoRole.consumer:
        return 'Consumer';
      case DemoRole.seller:
        return 'Seller';
      case DemoRole.volunteer:
        return 'Volunteer';
      case DemoRole.ngo:
        return 'NGO';
    }
  }

  IconData get icon {
    switch (this) {
      case DemoRole.consumer:
        return Icons.shopping_bag_outlined;
      case DemoRole.seller:
        return Icons.storefront_outlined;
      case DemoRole.volunteer:
        return Icons.volunteer_activism_outlined;
      case DemoRole.ngo:
        return Icons.groups_outlined;
    }
  }
}

class RoleSwitcher extends StatelessWidget {
  final DemoRole activeRole;
  final ValueChanged<DemoRole> onRoleChanged;

  const RoleSwitcher({
    super.key,
    required this.activeRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.full),
        border: Border.all(color: AnnvaColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: DemoRole.values.map((role) {
          final isActive = role == activeRole;
          return GestureDetector(
            onTap: () => onRoleChanged(role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AnnvaColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AnnvaRadius.full),
              ),
              child: Text(
                role.label,
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AnnvaColors.primaryForeground
                      : AnnvaColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
