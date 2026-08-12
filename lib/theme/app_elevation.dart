import 'package:flutter/material.dart';

class AppElevation {
  static List<BoxShadow> get minimal => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
