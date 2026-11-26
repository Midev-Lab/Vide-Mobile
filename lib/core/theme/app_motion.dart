class AppMotion {
  AppMotion._();

  static const drawerDuration = Duration(milliseconds: 280);
  static const chatComposerDuration = Duration(milliseconds: 200);
  static const chatComposerIconDuration = Duration(milliseconds: 100);
  static const buttonPressDuration = Duration(milliseconds: 120);
  static const double drawerOpenThreshold = 0.5;
  static const double drawerFlingVelocity = 700;
  static const double buttonRestScale = 1;
  static const double buttonPressedScale = 0.97;
  static const double chatComposerButtonPressedScale = 0.95;

  // ─── Attach sheet ──────────────────────────────────────────────────────
  static const sheetOpenDuration = Duration(milliseconds: 280);
  static const sheetCloseDuration = Duration(milliseconds: 220);
  static const sheetShimmerDuration = Duration(milliseconds: 900);
  static const double sheetTilePressedScale = 0.97;

  // ─── Attach scanner ────────────────────────────────────────────────────
  static const attachSheetPreviewFadeDuration = Duration(milliseconds: 200);
  static const attachSheetScannerDuration = Duration(milliseconds: 350);

  // ─── Focus timer ────────────────────────────────────────────────────────
  static const focusPopoverOpenDuration = Duration(milliseconds: 180);
  static const focusTimerSwitcherDuration = Duration(milliseconds: 200);
  static const focusTimerTickInterval = Duration(seconds: 1);
  static const focusFinishNoticeDuration = Duration(seconds: 2);
  static const double focusPopoverStartScale = 0.92;
}
