import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const drawerFloating = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 18,
    offset: Offset(-4, 4),
  );

  static const List<BoxShadow> pageEdgeShadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 32,
      offset: Offset(-8, 0),
    ),
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(-1, 0),
    ),
  ];
}
