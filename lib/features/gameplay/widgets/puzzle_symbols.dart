import 'package:flutter/material.dart';

/// Symbol keys authored in puzzle content, rendered with the bundled Material
/// icon font so every symbol stays offline (PLAN §1.2, §5.1).
///
/// Unknown keys return `null`; callers fall back to the option's authored text
/// so new content never renders a blank card.
IconData? puzzleSymbolIcon(String key) => switch (key) {
  'circle' || 'symbol_circle' => Icons.circle_outlined,
  'square' || 'symbol_square' => Icons.crop_square,
  'triangle' || 'symbol_triangle' => Icons.change_history,
  'pentagon' || 'symbol_pentagon' => Icons.pentagon_outlined,
  'star' || 'symbol_star' => Icons.star_border,
  'moon' || 'symbol_moon' => Icons.dark_mode_outlined,
  'leaf' || 'symbol_leaf' => Icons.eco_outlined,
  _ => null,
};
