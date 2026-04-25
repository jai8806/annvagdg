import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/annva_colors.dart';

/// Animated impact ticker — shows a number that ticks up periodically.
///
/// Visual spec (Section 6.4):
/// - Numbers animate with slide-up transition (like a slot machine digit)
/// - Font: Instrument Serif display size
/// - Data: starts from mock LIVE_IMPACT values, ticks up +1 to +4 every 2.2s
/// - Uses AnimatedSwitcher with custom transition
class ImpactTicker extends StatefulWidget {
  /// Starting value for the counter.
  final int initialValue;

  /// Label shown below the number (e.g., "kg rescued").
  final String label;

  /// Font size for the number.
  final double fontSize;

  /// Color for the number. Defaults to AnnvaColors.primary.
  final Color? numberColor;

  /// How often to tick (defaults to 2.2 seconds).
  final Duration tickInterval;

  /// Max increment per tick (random 1..maxIncrement).
  final int maxIncrement;

  const ImpactTicker({
    super.key,
    required this.initialValue,
    required this.label,
    this.fontSize = 40,
    this.numberColor,
    this.tickInterval = const Duration(milliseconds: 2200),
    this.maxIncrement = 4,
  });

  @override
  State<ImpactTicker> createState() => _ImpactTickerState();
}

class _ImpactTickerState extends State<ImpactTicker> {
  late int _currentValue;
  late Timer _timer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _timer = Timer.periodic(widget.tickInterval, (_) {
      setState(() {
        _currentValue += 1 + _random.nextInt(widget.maxIncrement);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Format number with Indian commas (e.g., 4,87,312).
  String _formatIndian(int n) {
    if (n < 1000) return '$n';
    final str = n.toString();
    final lastThree = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);
    if (remaining.isEmpty) return lastThree;
    final buffer = StringBuffer();
    for (var i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    return '$buffer,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.numberColor ?? AnnvaColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated number — slot-machine style, no overlap
        // Outgoing slides UP and fades out, incoming slides FROM BELOW
        ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              // Incoming child (0→1): key matches current value
              // Outgoing child (1→0): key is the previous value
              final isIncoming =
                  child.key == ValueKey<int>(_currentValue);

              final slideTween = isIncoming
                  // Incoming: start below (Y=1), end in place (Y=0)
                  ? Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    )
                  // Outgoing: at value=1 → Y=0 (in place),
                  //           at value=0 → Y=-1 (slid up out)
                  : Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    );

              return SlideTransition(
                position: slideTween.animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              _formatIndian(_currentValue),
              key: ValueKey<int>(_currentValue),
              style: GoogleFonts.instrumentSerif(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Label below the number
        Text(
          widget.label,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AnnvaColors.muted,
          ),
        ),
      ],
    );
  }
}
