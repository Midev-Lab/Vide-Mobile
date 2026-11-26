import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';

/// Shows a modal bottom sheet that supports swipe-down to dismiss.
///
/// * Includes a drag handle by default; pass `showDragHandle: false` to draw a custom one.
/// * Uses the theme's [BottomSheetThemeData] for shape / color.
/// * [useLargeRadius] switches between 24 px and 32 px top corners.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useLargeRadius = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
  bool showDragHandle = true,
  Color? backgroundColor,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    backgroundColor:
        backgroundColor ?? Theme.of(context).bottomSheetTheme.backgroundColor,
    barrierColor: barrierColor,
    shape: RoundedRectangleBorder(
      borderRadius: useLargeRadius
          ? AppRadii.sheetsTopLarge
          : AppRadii.sheetsTopSmall,
    ),
    builder: builder,
  );
}
