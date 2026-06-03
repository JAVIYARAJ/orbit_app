import 'package:flutter/material.dart';

/// Single source of truth for every colour in the app.
///
/// Views must reference these tokens — no raw `Color(0x…)` literals in UI code.
/// Names map to the source design's Tailwind / oklch tokens; shade suffixes
/// (e.g. [amber600]) denote specific variants used by particular screens.
abstract final class AppColors {
  AppColors._();

  // ── Base ────────────────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // ── Backgrounds ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A); // neutral-950
  static const Color backgroundDeep = Color(0xFF0D0F12); // splash backdrop

  // ── Surfaces (cards, inputs, chips) ───────────────────────────────────────────
  static const Color surface = Color(0xFF171717); // neutral-900
  static const Color surfaceAlt = Color(0xFF161A1F); // bluish cards / drawer
  static const Color surfaceRaised = Color(0xFF1C1C1C); // login form card
  static const Color inputFill = Color(0xFF101010); // login input field
  static const Color chip = Color(0xFF262626); // neutral-800 (chips/avatars)

  // ── Borders ───────────────────────────────────────────────────────────────────
  static const Color borderFaint = Color(0x1AFFFFFF); // white/10
  static const Color borderInput = Color(0x26FFFFFF); // white/15
  static const Color borderCard = Color(0xFF1E2530); // bluish card border
  static const Color borderNeutral = Color(0xFF282828); // neutral-800 border
  static const Color divider = borderFaint;

  // ── Text / neutrals ─────────────────────────────────────────────────────────────
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA1A1A1);
  static const Color neutral550 = Color(0xFF636363); // muted timestamps
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);

  // ── Brand / indigo ───────────────────────────────────────────────────────────────
  static const Color brand = Color(0xFF1F3CE6); // oklch(0.488 0.243 264.376)
  static const Color brandSoft = Color(
    0xFF6E8BFF,
  ); // lighter indigo (text/tags)
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);

  // ── Accents ───────────────────────────────────────────────────────────────────
  static const Color emerald = Color(0xFF10B981);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color teal = Color(0xFF0FBA81);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber600 = Color(0xFFD97706);
  static const Color rose = Color(0xFFFF6467);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color purple = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color cyan = Color(0xFF22D3EE);

  // ── Third-party brand (social sign-in) ──────────────────────────────────────────
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);
}
