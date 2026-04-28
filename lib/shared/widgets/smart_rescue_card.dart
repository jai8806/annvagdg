import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';
import '../../core/theme/annva_text_styles.dart';
import '../../core/services/gemini_service.dart';
import '../models/food_listing.dart';

class SmartRescueCard extends StatelessWidget {
  final FoodListing listing;
  const SmartRescueCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: GeminiService.generateSmartRescueCard(
        listingId: listing.id,
        dishName: listing.name,
        vertical: listing.vertical,
        diet: listing.diet.join(', '),
        isRefrigerated: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildShimmer();
        return _buildCard(context, snapshot.data!);
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(AnnvaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(children: [
            Text('SMART RESCUE', style: AnnvaTextStyles.label),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome, size: 10, 
                  color: Color(0xFF1A73E8)),
                const SizedBox(width: 3),
                const Text('Gemini', style: TextStyle(
                  fontSize: 10, color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'WorkSans')),
              ]),
            ),
          ]),

          const SizedBox(height: 12),

          // Safe window — most important, first
          Row(children: [
            const Icon(Icons.timer_outlined, 
              size: 15, color: AnnvaColors.cascadeFresh),
            const SizedBox(width: 6),
            Expanded(child: Text(
              data['safeWindow'] ?? '',
              style: AnnvaTextStyles.bodySmall,
            )),
          ]),

          const Divider(color: AnnvaColors.border, height: 20, thickness: 0.5),

          // Nutrition row — 4 chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutriChip('Cal', data['calories'] ?? '-', 
                AnnvaColors.ochre),
              _nutriChip('Protein', data['protein'] ?? '-', 
                AnnvaColors.cascadeFresh),
              _nutriChip('Carbs', data['carbs'] ?? '-', 
                AnnvaColors.primary),
              _nutriChip('Fat', data['fat'] ?? '-', 
                AnnvaColors.muted),
            ],
          ),

          const Divider(color: AnnvaColors.border, height: 20, thickness: 0.5),

          // Allergens
          if (data['allergens'] != null && 
              data['allergens'] != 'None') ...[
            Row(children: [
              const Icon(Icons.warning_amber_outlined, 
                size: 14, color: AnnvaColors.cascadeUrgent),
              const SizedBox(width: 6),
              Expanded(child: Text(
                'Contains: ${data['allergens']}',
                style: AnnvaTextStyles.bodySmall
                  .copyWith(color: AnnvaColors.cascadeUrgent),
              )),
            ]),
            const SizedBox(height: 4),
          ],

          // Dietary flags
          if (data['dietaryFlags'] != null && 
              data['dietaryFlags'] != 'Not applicable') ...[
            Row(children: [
              const Icon(Icons.check_circle_outline, 
                size: 14, color: AnnvaColors.cascadeFresh),
              const SizedBox(width: 6),
              Expanded(child: Text(
                data['dietaryFlags']!,
                style: AnnvaTextStyles.bodySmall
                  .copyWith(color: AnnvaColors.cascadeFresh),
              )),
            ]),
            const SizedBox(height: 4),
          ],

          // Best for
          Row(children: [
            const Icon(Icons.people_outlined, 
              size: 14, color: AnnvaColors.muted),
            const SizedBox(width: 6),
            Expanded(child: Text(
              'Best for: ${data['bestFor'] ?? ''}',
              style: AnnvaTextStyles.bodySmall,
            )),
          ]),

          const SizedBox(height: 8),

          // Fun fact
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AnnvaColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AnnvaRadius.md),
            ),
            child: Text(
              '\u2728 ${data['funFact'] ?? ''}',
              style: AnnvaTextStyles.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AnnvaColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutriChip(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(
        fontFamily: 'WorkSans', fontSize: 14,
        fontWeight: FontWeight.w600, color: color,
      )),
      Text(label, style: TextStyle(
        fontFamily: 'WorkSans', fontSize: 10,
        color: AnnvaColors.muted,
      )),
    ]);
  }

  Widget _buildShimmer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(AnnvaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('SMART RESCUE', style: AnnvaTextStyles.label),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Gemini', style: TextStyle(
                fontSize: 10, color: Color(0xFF1A73E8))),
            ),
          ]),
          const SizedBox(height: 16),
          // Shimmer bars
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 12,
              width: i == 1 ? 200 : i == 3 ? 150 : double.infinity,
              decoration: BoxDecoration(
                color: AnnvaColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .fade(begin: 0.3, end: 0.8, duration: 800.ms),
          )),
          const Center(child: Text('Analysing with Gemini...',
            style: AnnvaTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
