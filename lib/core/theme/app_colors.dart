import 'package:flutter/material.dart';

/// All color tokens for VIDE, organised by brightness.
///
/// Access via [AppColors.light] or [AppColors.dark].
class AppColors {
  const AppColors._({
    required this.green,
    required this.background,
    required this.card,
    required this.line,
    required this.hover,
    required this.ink,
    required this.gray,
    required this.send,
    required this.yellow,
    required this.onYellow,
    required this.error,
    required this.activeRow,
    required this.sidebar,
    required this.frame,
    required this.foreground,
    required this.sidebarSurface,
    required this.sidebarLine,
    required this.sidebarMuted,
    required this.scrim,
    required this.white,
    required this.overlayFill,
    required this.overlayStroke,
    required this.cameraScannerBackground,
  });

  // ─── Tokens ──────────────────────────────────────────────────────────
  final Color green;
  final Color background;
  final Color card;
  final Color line;
  final Color hover;
  final Color ink;
  final Color gray;
  final Color send;
  final Color yellow;
  final Color onYellow;
  final Color error;
  final Color activeRow;
  final Color sidebar;
  final Color frame;
  final Color foreground;
  final Color sidebarSurface;
  final Color sidebarLine;
  final Color sidebarMuted;
  final Color scrim;
  final Color white;
  final Color overlayFill;
  final Color overlayStroke;

  // ─── Attach scanner ──────────────────────────────────────────────────
  final Color cameraScannerBackground;

  // ─── Light palette ───────────────────────────────────────────────────
  static const light = AppColors._(
    green: Color(0xFF005548),
    background: Color(0xFFF6F0E0),
    card: Color(0xFFFDFAF0),
    line: Color(0xFFDDD7C9),
    hover: Color(0xFFEDE6D3),
    ink: Color(0xFF111111),
    gray: Color(0xFF6A7282),
    send: Color(0xFF7AA193),
    yellow: Color(0xFFF4BC14),
    onYellow: Color(0xFF3A2E00),
    error: Color(0xFFB8453D),
    activeRow: Color(0xFF266E63),
    // Not used in light – fallback to transparent.
    sidebar: Colors.transparent,
    frame: Colors.transparent,
    foreground: Colors.transparent,
    sidebarSurface: Color(0xFF1B5E52),
    sidebarLine: Color(0xFF34796D),
    sidebarMuted: Color(0xFFA9C4BB),
    scrim: Color(0x66000000),
    white: Colors.white,
    overlayFill: Color(0x14FFFFFF),
    overlayStroke: Color(0x24FFFFFF),
    cameraScannerBackground: Color(0xFF000000),
  );

  // ─── Dark palette ────────────────────────────────────────────────────
  static const dark = AppColors._(
    green: Color(0xFF005548),
    background: Color(0xFF0F1F1B),
    card: Color(0xFF162B26),
    line: Color(0xFF2B433C),
    hover: Color(0xFF1D352F),
    ink: Color(0xFFE8EDE9),
    gray: Color(0xFF8FA39A),
    send: Color(0xFF2E7D6B),
    yellow: Color(0xFFF4BC14),
    onYellow: Color(0xFF3A2E00),
    error: Color(0xFFB8453D),
    activeRow: Color(0xFF14574B),
    sidebar: Color(0xFF00372F),
    frame: Color(0xFF08130F),
    foreground: Color(0xFFD3E6DE),
    sidebarSurface: Color(0xFF1D4C43),
    sidebarLine: Color(0xFF3B5D55),
    sidebarMuted: Color(0xFF8FA39A),
    scrim: Color(0x66000000),
    white: Colors.white,
    overlayFill: Color(0x14FFFFFF),
    overlayStroke: Color(0x24FFFFFF),
    cameraScannerBackground: Color(0xFF000000),
  );

  /// Convenience resolver.
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// Opacity values used for de-emphasised content and tap feedback.
class AppOpacity {
  AppOpacity._();

  static const double transparent = 0;
  static const double opaque = 1;
  static const double muted = 0.55;
  static const double subtle = 0.70;
  static const double secondary = 0.75;
  static const double ripple = 0.08;
  static const double attachSheetScrim = 0.35;
  static const double attachSheetIconFill = 0.10;
  static const double attachSheetBorder = 0.25;

  // ─── Attach scanner ──────────────────────────────────────────────────
  static const double attachSheetScannerSubtitle = 0.75;
  static const double attachSheetScannerScrim = 0.70;
  static const double attachSheetAddChatSubtitle = 0.70;

  // ─── Focus timer ────────────────────────────────────────────────────────
  static const double focusTimerPausedFill = 0.62;
  static const double focusPopoverBorder = 0.18;
  static const double focusPopoverShadow = 0.10;
}
