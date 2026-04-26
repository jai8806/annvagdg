import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/annva_colors.dart';

/// Live countdown timer for food listings.
///
/// Visual spec (Section 6.3):
/// - Large countdown: 1h 24m 38s
/// - Instrument Serif, ochre when <2h, red when <30min
/// - Updates every second via Timer.periodic — does NOT poll Firebase
/// - Takes a DateTime expiresAt, computes locally
class UrgencyTimer extends StatefulWidget {
  /// The expiration timestamp for this listing.
  final DateTime expiresAt;

  /// Font size for the countdown digits.
  final double fontSize;

  /// Whether to show seconds in the countdown.
  final bool showSeconds;

  /// Callback when the timer reaches zero.
  final VoidCallback? onExpired;

  const UrgencyTimer({
    super.key,
    required this.expiresAt,
    this.fontSize = 15,
    this.showSeconds = false,
    this.onExpired,
  });

  @override
  State<UrgencyTimer> createState() => _UrgencyTimerState();
}

class _UrgencyTimerState extends State<UrgencyTimer> {
  late Timer _timer;
  late Duration _remaining;
  bool _hasExpired = false;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _computeRemaining();
    });
  }

  @override
  void didUpdateWidget(UrgencyTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _hasExpired = false;
      _computeRemaining();
    }
  }

  void _computeRemaining() {
    final now = DateTime.now();
    final diff = widget.expiresAt.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
    if (_remaining == Duration.zero && !_hasExpired) {
      _hasExpired = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Determine countdown colour based on urgency.
  Color get _timerColor {
    if (_remaining.inMinutes < 30) return AnnvaColors.cascadeUrgent;
    if (_remaining.inHours < 2) return AnnvaColors.ochre;
    return AnnvaColors.muted;
  }

  /// Format the remaining duration as a readable string.
  String get _formattedTime {
    if (_remaining == Duration.zero) return 'Expired';
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    if (widget.showSeconds) {
      if (hours > 0) {
        return '${hours}h ${_pad(minutes)}m ${_pad(seconds)}s';
      }
      return '${minutes}m ${_pad(seconds)}s';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    return '${minutes}m left';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: widget.fontSize + 2,
          color: _timerColor,
        ),
        const SizedBox(width: 4),
        Text(
          _formattedTime,
          style: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w500,
            color: _timerColor,
          ),
        ),
      ],
    );
  }
}
