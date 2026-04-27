import 'package:flutter/material.dart';

import '../../core/theme/annva_colors.dart';

/// "अन्न Annva" wordmark — the app's logotype.
///
/// Visual spec (Section 6.11):
/// - Always show the Devanagari "अन्नवा" first, then the Latin "Annva"
/// - Noto Serif Devanagari for "अन्नवा", Instrument Serif for "Annva"
/// - Deep indigo, side by side
/// - Never show just "Annva" without the Devanagari prefix
class AnnvaLogo extends StatelessWidget {
  /// Font size for the Devanagari part.
  final double fontSize;

  /// Color override. Defaults to AnnvaColors.primary.
  final Color? color;

  const AnnvaLogo({super.key, this.fontSize = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AnnvaColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Devanagari: अन्नवा
        Text(
          'अन्नवा',
          style: TextStyle(
            fontFamily: 'NotoSerifDevanagari',
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        SizedBox(width: fontSize * 0.25),
        // Latin: Annva
        Text(
          'Annva',
          style: TextStyle(
            fontFamily: 'InstrumentSerif',
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
