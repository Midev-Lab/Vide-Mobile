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
  static const IconData caretRight = PhosphorIconsRegular.caretRight;
  static const IconData arrowUp = PhosphorIconsRegular.arrowUp;
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData layers = PhosphorIconsRegular.stack;
  static const IconData person = PhosphorIconsRegular.user;
  static const IconData signOut = PhosphorIconsRegular.signOut;
  static const IconData x = PhosphorIconsRegular.x;

  // ─── Attach menu ───────────────────────────────────────────────────────
  static const IconData file = PhosphorIconsRegular.file;
  static const IconData fileArrowUp = PhosphorIconsRegular.fileArrowUp;
  static const IconData image = PhosphorIconsRegular.image;
  static const IconData camera = PhosphorIconsRegular.camera;

  // ─── Attach menu (fill states) ─────────────────────────────────────────
  static const IconData fileFill = PhosphorIconsFill.file;
  static const IconData fileArrowUpFill = PhosphorIconsFill.fileArrowUp;
  static const IconData imageFill = PhosphorIconsFill.image;
  static const IconData cameraFill = PhosphorIconsFill.camera;

  // ─── Attach scanner ───────────────────────────────────────────────────
  static const IconData cameraRotate = PhosphorIconsRegular.cameraRotate;
  static const IconData flashlight = PhosphorIconsRegular.flashlight;
  static const IconData lightning = PhosphorIconsRegular.lightning;
  static const IconData flashlightFill = PhosphorIconsFill.flashlight;

  // ─── Composer ──────────────────────────────────────────────────────────
  static const IconData waveform = PhosphorIconsRegular.waveform;

  // ─── Sidebar ───────────────────────────────────────────────────────────
  static const IconData chat = PhosphorIconsRegular.chatCircle;
  static const IconData chatFill = PhosphorIconsFill.chatCircle;
  static const IconData cards = PhosphorIconsRegular.cards;
  static const IconData moon = PhosphorIconsRegular.moon;
  static const IconData sparkle = PhosphorIconsRegular.sparkle;
  static const IconData settings = PhosphorIconsRegular.gear;

  // ─── Selected states ───────────────────────────────────────────────────
  static const IconData checkActive = PhosphorIconsFill.check;

  // ─── Focus timer ────────────────────────────────────────────────────────
  static const IconData timer = PhosphorIconsRegular.timer;
  static const IconData timerFill = PhosphorIconsFill.timer;
  static const IconData minus = PhosphorIconsRegular.minus;
  static const IconData pause = PhosphorIconsRegular.pause;
  static const IconData play = PhosphorIconsRegular.play;
}
