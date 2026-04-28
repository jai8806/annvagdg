import 'package:flutter/material.dart';
import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';

enum TrustBadgeType {
  certified('ANNVA FreshTrust Certified', Icons.verified),
  partner('ANNVA Verified Partner', Icons.handshake_outlined);

  final String label;
  final IconData icon;
  const TrustBadgeType(this.label, this.icon);
}

class TrustBadge extends StatelessWidget {
  final TrustBadgeType type;

  const TrustBadge({
    super.key,
    this.type = TrustBadgeType.certified,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == TrustBadgeType.certified 
        ? AnnvaColors.ochre 
        : AnnvaColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AnnvaRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
