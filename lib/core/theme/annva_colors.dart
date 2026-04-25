import 'package:flutter/material.dart';

/// Annva Design System — Colour Constants
///
/// Heritage Indigo palette: three colours that appear on every Indian thali.
/// Deep Indigo (trust), Cream (warmth), Ochre (energy).
///
/// Rules:
/// - Never use pure white (#FFFFFF) as a background — always cream
/// - Never use pure black (#000000) for text — always ink (near-black indigo)
/// - Never use cool grays — all neutrals have warm ochre undertones
class AnnvaColors {
  AnnvaColors._();

  // === BACKGROUNDS ===
  /// hsl(39 38% 93%) — cream paper
  static const Color background = Color(0xFFF2E8D5);

  /// hsl(40 35% 96%) — light cream card
  static const Color backgroundCard = Color(0xFFF7F0E3);

  /// Even lighter cream for mini-bar
  static const Color creamLight = Color(0xFFFDF9F1);

  /// hsl(38 30% 88%) — soft cream
  static const Color backgroundSecondary = Color(0xFFE8D9BF);

  // === TEXT / INK ===
  /// hsl(215 70% 8%) — near-black
  static const Color ink = Color(0xFF07152B);

  /// hsl(215 52% 11%) — deep navy text
  static const Color foreground = Color(0xFF0F2240);

  /// hsl(215 20% 35%) — muted text
  static const Color muted = Color(0xFF4A5A72);

  /// Muted labels
  static const Color mutedForeground = Color(0xFF6B7A8F);

  // === PRIMARY — DEEP INDIGO ===
  /// hsl(213 52% 24%) — main brand
  static const Color primary = Color(0xFF1D3F6E);

  /// hsl(215 70% 18%) — hover/pressed
  static const Color primaryDeep = Color(0xFF0F2D5C);

  /// Text on primary background
  static const Color primaryForeground = Color(0xFFF2E8D5);

  // === ACCENT — OCHRE ===
  /// hsl(36 78% 57%) — main accent
  static const Color ochre = Color(0xFFE09A1C);

  /// hsl(30 65% 42%) — darker ochre
  static const Color ochreDeep = Color(0xFFAE6B24);

  /// Text on ochre background
  static const Color ochreForeground = Color(0xFF0F2240);

  // === BORDERS ===
  /// hsl(38 22% 78%)
  static const Color border = Color(0xFFCDBD9E);

  /// hsl(38 22% 82%) — inputs
  static const Color borderLight = Color(0xFFD6C8A8);

  // === CASCADE STAGES — THE CORE PRODUCT LOGIC ===
  /// hsl(142 45% 38%) — green, 0-1h
  static const Color cascadeFresh = Color(0xFF2E7D52);
  static const Color cascadeFreshBg = Color(0xFFDFF2E8);

  /// 1-2h
  static const Color cascadeGoodDeal = Color(0xFF4A9E6B);
  static const Color cascadeGoodDealBg = Color(0xFFE8F5EE);

  /// hsl(36 78% 57%) — ochre, 2–3h
  static const Color cascadeMid = Color(0xFFE09A1C);
  static const Color cascadeMidBg = Color(0xFFFEF3DC);

  /// 3-3.5h
  static const Color cascadeLastCall = Color(0xFFE05A1C);
  static const Color cascadeLastCallBg = Color(0xFFFBECE6);

  /// hsl(8 72% 50%) — red, 3.5-4h
  static const Color cascadeUrgent = Color(0xFFD63B1A);
  static const Color cascadeUrgentBg = Color(0xFFFDEAE6);

  // === DARK MODE EQUIVALENTS ===
  /// hsl(215 70% 8%)
  static const Color backgroundDark = Color(0xFF07152B);

  /// hsl(215 50% 12%)
  static const Color cardDark = Color(0xFF0C1F3A);

  /// hsl(215 40% 22%)
  static const Color borderDark = Color(0xFF1A3050);
}
