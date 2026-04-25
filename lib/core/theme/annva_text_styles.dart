import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'annva_colors.dart';

/// Annva Design System — Typography
///
/// Three font families:
/// - Instrument Serif: headings, hero numbers, brand logotype (weight 400)
/// - Work Sans: body, UI text, labels, buttons (weights 300–700)
/// - Noto Serif Devanagari: Hindi/Sanskrit elements, "अन्न" in logo (weights 400, 700)
class AnnvaTextStyles {
  AnnvaTextStyles._();

  // ─── DISPLAY — hero numbers, big impact stats ───
  static TextStyle display = GoogleFonts.instrumentSerif(
    fontSize: 56,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: AnnvaColors.primary,
  );

  // ─── H1 — screen titles ───
  static TextStyle h1 = GoogleFonts.instrumentSerif(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    color: AnnvaColors.primary,
  );

  // ─── H2 — section headings ───
  static TextStyle h2 = GoogleFonts.instrumentSerif(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AnnvaColors.primary,
  );

  // ─── H3 — card titles ───
  static TextStyle h3 = GoogleFonts.instrumentSerif(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AnnvaColors.primary,
  );

  // ─── BODY — standard text ───
  static TextStyle body = GoogleFonts.workSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AnnvaColors.foreground,
  );

  // ─── BODY SMALL — secondary text, descriptions ───
  static TextStyle bodySmall = GoogleFonts.workSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AnnvaColors.muted,
  );

  // ─── LABEL — uppercase tracking labels (section labels, tag headers) ───
  /// Always ochre, 10px, 1.2em letter-spacing, Work Sans 500
  static TextStyle label = GoogleFonts.workSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AnnvaColors.ochre,
  );

  // ─── BUTTON — CTA text ───
  static TextStyle button = GoogleFonts.workSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AnnvaColors.primaryForeground,
  );

  // ─── PRICE — food item prices ───
  static TextStyle price = GoogleFonts.workSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AnnvaColors.primary,
  );

  // ─── PRICE STRIKETHROUGH — original price ───
  static TextStyle priceOriginal = GoogleFonts.workSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AnnvaColors.muted,
    decoration: TextDecoration.lineThrough,
  );

  // ─── DEVANAGARI — Sanskrit/Hindi elements ───
  static TextStyle devanagari = GoogleFonts.notoSerifDevanagari(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AnnvaColors.primary,
  );

  // ─── DEVANAGARI WATERMARK — large background text, very low opacity ───
  static TextStyle devanagariWatermark = GoogleFonts.notoSerifDevanagari(
    fontSize: 120,
    fontWeight: FontWeight.w700,
    color: AnnvaColors.primary.withValues(alpha: 0.04),
  );

  // ─── MONO / HASH — blockchain certificate hashes ───
  static TextStyle mono = const TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    color: AnnvaColors.muted,
  );
}
