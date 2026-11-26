import 'package:flutter/material.dart';

/// Shared border-radius constants for VIDE.
class AppRadii {
  AppRadii._();

  // ─── Raw values ──────────────────────────────────────────────────────
  static const double pillValue = 999;
  static const double composerValue = 22;
  static const double cardsValue = 18;
  static const double menuValue = 16;
  static const double optionValue = 10;
  static const double drawerNavValue = 12;
  static const double drawerPageValue = 36;
  static const double chatComposerExpandedValue = 28;
  static const double searchValue = 9;
  static const double rowValue = 8;
  static const double sidebarPopupValue = 14;
  static const double tagValue = 4;
  static const double sheetsTopSmallValue = 24;
  static const double sheetsTopLargeValue = 32;

  // ─── BorderRadius helpers ────────────────────────────────────────────
  static final pill = BorderRadius.circular(pillValue);
  static final composer = BorderRadius.circular(composerValue);
  static final cards = BorderRadius.circular(cardsValue);
  static final menu = BorderRadius.circular(menuValue);
  static final option = BorderRadius.circular(optionValue);
  static final drawerNav = BorderRadius.circular(drawerNavValue);
  static final chatComposerExpanded = BorderRadius.circular(
    chatComposerExpandedValue,
  );
  static final search = BorderRadius.circular(searchValue);
  static final row = BorderRadius.circular(rowValue);
  static final sidebarPopup = BorderRadius.circular(sidebarPopupValue);
  static final tag = BorderRadius.circular(tagValue);

  /// Bottom-sheet top corners (small variant – 24 px).
  static const sheetsTopSmall = BorderRadius.only(
    topLeft: Radius.circular(sheetsTopSmallValue),
    topRight: Radius.circular(sheetsTopSmallValue),
  );

  /// Bottom-sheet top corners (large variant – 32 px).
  static const sheetsTopLarge = BorderRadius.only(
    topLeft: Radius.circular(sheetsTopLargeValue),
    topRight: Radius.circular(sheetsTopLargeValue),
  );
}
