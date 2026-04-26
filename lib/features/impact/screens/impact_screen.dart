import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';

class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Text('Impact', style: AnnvaTextStyles.h1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO IMPACT STATS (2x2 Grid)
            _buildHeroGrid(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 2. NGO FUND (Forfeited Deposits)
            _buildNGOFundSection(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 3. WEEKLY RESCUE CHART
            Text(
              'WEEKLY RESCUES · KG',
              style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
            ),
            const SizedBox(height: AnnvaSpacing.md),
            _buildWeeklyChart(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 4. CITY BREAKDOWN
            Text(
              'RESCUES BY CITY',
              style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
            ),
            const SizedBox(height: AnnvaSpacing.md),
            _buildCityBreakdown(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 5. PARTNER LOGOS
            Text(
              'RESCUE PARTNERS',
              style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
            ),
            const SizedBox(height: AnnvaSpacing.md),
            _buildPartners(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 6. PRASAD PROTOCOL
            Text(
              'PRASAD PROTOCOL',
              style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
            ),
            Text(
              'Sacred surplus, rescued daily',
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AnnvaSpacing.md),
            _buildPrasadProtocol(),
            const SizedBox(height: AnnvaSpacing.xxl),

            // 7. ANNAPURNA PROTOCOL CTA
            _buildAnnapurnaCTA(context),
            const SizedBox(height: AnnvaSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: [
            _buildHeroCard(
              label: 'KG RESCUED',
              value: '4,87,312',
              subtext: '+1,240 this week',
              isPrimary: true,
            ),
            _buildHeroCard(
              label: 'MEALS DELIVERED',
              value: '19,48,240',
              subtext: 'across 6 cities',
            ),
            _buildHeroCard(
              label: 'CO₂ AVOIDED',
              value: '12,36,478 kg',
              subtext: '= 2,680 cars off road for a day',
              valueSize: 40,
            ),
            _buildHeroCard(
              label: 'CITIES LIVE',
              value: '6',
              subtext:
                  'Bengaluru · Mumbai · Delhi · Pune · Chennai · Hyderabad',
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroCard({
    required String label,
    required String value,
    required String subtext,
    bool isPrimary = false,
    double valueSize = 48,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? AnnvaColors.primary : AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: isPrimary ? null : Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AnnvaTextStyles.label.copyWith(
              color: isPrimary
                  ? AnnvaColors.creamLight.withValues(alpha: 0.7)
                  : AnnvaColors.ochre,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AnnvaTextStyles.h1.copyWith(
              color: isPrimary ? AnnvaColors.creamLight : AnnvaColors.primary,
              fontSize: valueSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontFamily: 'WorkSans',
              color: isPrimary
                  ? AnnvaColors.creamLight.withValues(alpha: 0.6)
                  : AnnvaColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 120,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 40,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AnnvaColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _buildBarGroup(0, 45),
            _buildBarGroup(1, 72),
            _buildBarGroup(2, 58),
            _buildBarGroup(3, 91),
            _buildBarGroup(4, 88),
            _buildBarGroup(5, 112, isSelected: true),
            _buildBarGroup(6, 67),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, {bool isSelected = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isSelected ? AnnvaColors.ochre : AnnvaColors.primary,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildCityBreakdown() {
    final cities = [
      {'name': 'Bengaluru', 'pct': 0.68, 'kg': '2,340'},
      {'name': 'Mumbai', 'pct': 0.12, 'kg': '412'},
      {'name': 'Delhi', 'pct': 0.08, 'kg': '275'},
      {'name': 'Pune', 'pct': 0.06, 'kg': '206'},
      {'name': 'Chennai', 'pct': 0.04, 'kg': '137'},
      {'name': 'Hyderabad', 'pct': 0.02, 'kg': '69'},
    ];

    return Column(
      children: cities.map((city) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  city['name'] as String,
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth * (city['pct'] as double);
                    return Row(
                      children: [
                        Container(
                          height: 12,
                          width: width.clamp(
                            4.0,
                            double.infinity,
                          ), // Min width for visibility
                          decoration: BoxDecoration(
                            color: AnnvaColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ).animate().scaleX(
                          alignment: Alignment.centerLeft,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  '${((city['pct'] as double) * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${city['kg']} kg',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.primary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPartners() {
    final partners = [
      'NCC',
      'NYKS',
      'NSS',
      'Akshaya Patra',
      'Robin Hood Army',
      'Feeding India',
      'Goonj',
      'The Better India',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: partners.map((partner) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AnnvaColors.backgroundCard,
              borderRadius: BorderRadius.circular(AnnvaRadius.full),
              border: Border.all(color: AnnvaColors.border),
            ),
            child: Text(
              partner,
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrasadProtocol() {
    final tiles = [
      {
        'title': 'Golden Temple, Amritsar',
        'subtitle': 'Langar surplus · Coming soon',
        'emoji': '🛕',
      },
      {
        'title': 'ISKCON Bengaluru',
        'subtitle': 'Prasad rescue · Pilot Q3 2026',
        'emoji': '🛕',
      },
      {
        'title': 'Tirupati Temple Trust',
        'subtitle': 'Partnership discussions',
        'emoji': '🛕',
      },
    ];

    return Column(
      children: tiles.map((tile) {
        return Container(
          margin: const EdgeInsets.only(bottom: AnnvaSpacing.sm),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AnnvaColors.backgroundCard,
            borderRadius: BorderRadius.circular(AnnvaRadius.xl),
            border: Border.all(color: AnnvaColors.border),
          ),
          child: Row(
            children: [
              Text(tile['emoji']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile['title']!,
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.bold,
                        color: AnnvaColors.primary,
                      ),
                    ),
                    Text(
                      tile['subtitle']!,
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNGOFundSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NGO RESCUE FUND',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
              const Spacer(),
              const Icon(Icons.favorite, color: Colors.red, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref('ngo_fund/total').onValue,
            builder: (context, snapshot) {
              final total = snapshot.data?.snapshot.value as num? ?? 0;
              return Text(
                '₹${total.toStringAsFixed(0)}',
                style: AnnvaTextStyles.h1.copyWith(
                  fontSize: 32,
                  color: AnnvaColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Forfeited deposits repurposed for NGO logistical support. No waste, only rescue.',
            style: TextStyle(
              fontFamily: 'WorkSans',
              color: AnnvaColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnapurnaCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnnvaColors.primary,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'अन्न ही ब्रह्म है',
            style: TextStyle(
              fontFamily: 'NotoSerifDevanagari',
              fontSize: 20,
              color: AnnvaColors.creamLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Register your event. We\'ll pre-position rescue.',
            style: TextStyle(
              fontFamily: 'WorkSans',
              color: AnnvaColors.creamLight.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Events page coming soon.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AnnvaColors.creamLight.withValues(alpha: 0.2),
              foregroundColor: AnnvaColors.creamLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AnnvaRadius.full),
              ),
            ),
            child: Text(
              'Register an event →',
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
