import 'package:flutter/material.dart';

/// Reusable text-style scale for VIDE.
///
/// **Fraunces** – main / display font.
/// **Inter** – small UI / secondary font.
class AppTextStyles {
  AppTextStyles._();

  // ─── Font families ───────────────────────────────────────────────────
  static const String _fraunces = 'Fraunces';
  static const String _inter = 'Inter';

  // ─── Fraunces-based styles ───────────────────────────────────────────

  /// Chat body text – 15.5 px, line-height 1.8
  static const chatBody = TextStyle(
    fontFamily: _fraunces,
    fontSize: 15.5,
    height: 1.8,
    fontWeight: FontWeight.w400,
  );

  /// User-sent message – 14.5 px
  static const userMessage = TextStyle(
    fontFamily: _fraunces,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
  );

  /// Section / page header – 15 px, semi-bold
  static const header = TextStyle(
    fontFamily: _fraunces,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Large empty-state greeting – 36 px
  static const emptyGreetingLarge = TextStyle(
    fontFamily: _fraunces,
    fontSize: 36,
    fontWeight: FontWeight.w500,
  );

  /// Smaller empty-state greeting – 24 px
  static const emptyGreetingSmall = TextStyle(
    fontFamily: _fraunces,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  /// Composer / input field text – 15.5 px
  static const input = TextStyle(
    fontFamily: _fraunces,
    fontSize: 15.5,
    fontWeight: FontWeight.w400,
  );

  // ─── Inter-based styles (small UI text) ──────────────────────────────

  /// Caption / helper text – 12 px
  static const caption = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// Button label – 14 px, medium
  static const button = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Small label – 13 px
  static const label = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// Overline / tiny UI text – 11 px, semi-bold
  static const overline = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const displayHero = TextStyle(
    fontFamily: _fraunces,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.68,
  );

  static const headingH1 = TextStyle(
    fontFamily: _fraunces,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
  );

  static const headingH2 = TextStyle(
    fontFamily: _fraunces,
    fontSize: 19,
    height: 25 / 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.19,
  );

  static const headingH3 = TextStyle(
    fontFamily: _fraunces,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
  );

  static const dashboardTitle = TextStyle(
    fontFamily: _fraunces,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );

  static const composerText = TextStyle(
    fontFamily: _fraunces,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  );

  static const uiBody = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const uiBodyMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  static const uiButton = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w600,
  );

  static const uiLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
  );

  static const uiCaption = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w400,
  );

  static const disclaimer = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w400,
  );

  static const sidebarSectionLabel = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.1,
  );

  static const sidebarTag = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.55,
  );

  static const sidebarRecentsLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const drawerItem = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const drawerSectionLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// UI/Badge Mono – 10 px, letter-spacing 0.04em.
  static const badgeMono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static const code = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    fontFeatures: [FontFeature.disable('liga'), FontFeature.disable('calt')],
  );
}
