import 'package:flutter/material.dart';

enum AttachActionKind { hero, utility, feature }

class AttachAction {
  const AttachAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.kind,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final AttachActionKind kind;
}
