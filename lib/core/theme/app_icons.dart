import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Single source of truth for the icons used by VIDE.
///
/// Screens and shared widgets must reference these names only; the Phosphor
/// package is imported here and nowhere else in `lib/`.
class AppIcons {
  AppIcons._();

  // ─── Chrome ────────────────────────────────────────────────────────────
  static const IconData menu = PhosphorIconsRegular.list;
  static const IconData plus = PhosphorIconsRegular.plus;
  static const IconData clock = PhosphorIconsRegular.clock;
  static const IconData caretDown = PhosphorIconsRegular.caretDown;
  static const IconData arrowUp = PhosphorIconsRegular.arrowUp;
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData layers = PhosphorIconsRegular.stack;
  static const IconData person = PhosphorIconsRegular.user;
  static const IconData signOut = PhosphorIconsRegular.signOut;

  // ─── Attach menu ───────────────────────────────────────────────────────
  static const IconData file = PhosphorIconsRegular.file;
  static const IconData image = PhosphorIconsRegular.image;

  // ─── Composer ──────────────────────────────────────────────────────────
  static const IconData waveform = PhosphorIconsRegular.waveform;

  // ─── Sidebar ───────────────────────────────────────────────────────────
  static const IconData chat = PhosphorIconsRegular.chatCircle;
  static const IconData cards = PhosphorIconsRegular.cards;
  static const IconData moon = PhosphorIconsRegular.moon;
  static const IconData sparkle = PhosphorIconsRegular.sparkle;
  static const IconData settings = PhosphorIconsRegular.gear;

  // ─── Selected states ───────────────────────────────────────────────────
  static const IconData checkActive = PhosphorIconsFill.check;
}
