import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/annva_spacing.dart';
import '../models/cascade_stage.dart';

/// Cascade stage badge with stage-specific animations.
///
/// Visual spec (Section 6.2):
/// - Fresh:  [ ● Fresh — 20% off  ]  green pill, no animation
/// - Mid:    [ ● Cascade — 50% off]  ochre pill, gentle glow
/// - Urgent: [ ● Final hour — Free]  red pill, pulsing ring
class CascadeBadge extends StatefulWidget {
  final CascadeStage stage;

  /// If true, shows the short label (e.g., "Fresh") instead of the full label.
  final bool compact;

  const CascadeBadge({
    super.key,
    required this.stage,
    this.compact = false,
  });

  @override
  State<CascadeBadge> createState() => _CascadeBadgeState();
}

class _CascadeBadgeState extends State<CascadeBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _startAnimationIfNeeded();
  }

  @override
  void didUpdateWidget(CascadeBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) {
      _controller.stop();
      _controller.duration = _animationDuration;
      _startAnimationIfNeeded();
    }
  }

  Duration get _animationDuration {
    switch (widget.stage) {
      case CascadeStage.hotDeal:
        return const Duration(milliseconds: 2400);
      case CascadeStage.lastCall:
        return const Duration(milliseconds: 2200);
      case CascadeStage.ngo:
        return const Duration(milliseconds: 2000);
      case CascadeStage.fresh:
      case CascadeStage.goodDeal:
        return Duration.zero;
    }
  }

  void _startAnimationIfNeeded() {
    if (widget.stage == CascadeStage.hotDeal ||
        widget.stage == CascadeStage.lastCall ||
        widget.stage == CascadeStage.ngo) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageColor = widget.stage.color;
    final label =
        widget.compact ? widget.stage.shortLabel : widget.stage.label;

    Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: stageColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AnnvaRadius.full),
        border: Border.all(
          color: stageColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stage dot indicator
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: stageColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // Stage label
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: stageColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    // Wrap with animation for mid and urgent stages
    if (widget.stage == CascadeStage.ngo || widget.stage == CascadeStage.lastCall) {
      badge = _buildPulsingRing(badge, stageColor);
    } else if (widget.stage == CascadeStage.hotDeal) {
      badge = _buildGentleGlow(badge, stageColor);
    }

    return badge;
  }

  /// Stage 3 urgent: pulsing red ring animation
  /// box-shadow: 0 0 0 0 cascadeUrgent(50%) → 0 0 0 12px cascadeUrgent(0%)
  Widget _buildPulsingRing(Widget child, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        final value = _pulseAnimation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AnnvaRadius.full),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5 * (1 - value)),
                blurRadius: 0,
                spreadRadius: 12 * value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// Stage 2 mid: gentle ochre glow animation
  /// box-shadow: 0 0 0 0 ochre(40%) → 0 0 0 8px ochre(0%)
  Widget _buildGentleGlow(Widget child, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        final value = _pulseAnimation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AnnvaRadius.full),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4 * (1 - value)),
                blurRadius: 0,
                spreadRadius: 8 * value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
