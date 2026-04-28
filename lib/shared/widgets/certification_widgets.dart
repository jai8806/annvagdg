import 'package:flutter/material.dart';
import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';
import '../../core/theme/annva_text_styles.dart';

/// A large professional card showing partner status (Gold, Silver, etc.)
class PartnerCertificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String badgeLabel;

  const PartnerCertificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.ochre.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.ochre.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildBadge(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are an',
                  style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.muted),
                ),
                Text(
                  title,
                  style: AnnvaTextStyles.h2.copyWith(color: AnnvaColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AnnvaColors.ochre,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AnnvaColors.ochre.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          Positioned(
            bottom: 12,
            child: Text(
              badgeLabel,
              style: const TextStyle(
                fontFamily: 'WorkSans',
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AnnvaColors.ochre,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View Certificate',
            style: TextStyle(
              fontFamily: 'WorkSans',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward, color: Colors.white, size: 12),
        ],
      ),
    );
  }
}

/// A minimal horizontal strip showing impact metrics (CO2, Water, etc.)
class ImpactSummaryStrip extends StatelessWidget {
  final List<ImpactMetric> metrics;

  const ImpactSummaryStrip({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: metrics.map((m) => _buildMetric(m)).toList(),
      ),
    );
  }

  Widget _buildMetric(ImpactMetric m) {
    return Column(
      children: [
        Row(
          children: [
            Icon(m.icon, size: 14, color: m.color),
            const SizedBox(width: 4),
            Text(
              m.value,
              style: const TextStyle(
                fontFamily: 'WorkSans',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AnnvaColors.primary,
              ),
            ),
          ],
        ),
        Text(
          m.label,
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

class ImpactMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const ImpactMetric(this.label, this.value, this.icon, this.color);
}

/// A credential list item used in the Profile/NGO section
class CredentialItem extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final IconData icon;
  final Color color;

  const CredentialItem({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildBadge(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AnnvaColors.primary,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 11,
                    color: AnnvaColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 11,
                    color: AnnvaColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.download_for_offline_outlined, color: AnnvaColors.muted, size: 20),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// A small vertical badge item for horizontal lists
class BadgeItem extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;
  final Color color;

  const BadgeItem({
    super.key,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AnnvaColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 9,
            color: AnnvaColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
