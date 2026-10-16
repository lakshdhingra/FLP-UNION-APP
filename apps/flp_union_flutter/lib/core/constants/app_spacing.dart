import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic layout tokens
  static const double screenPadding = 20.0;
  static const double screenPaddingLg = 24.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingLg = 20.0;

  // Common Insets
  static const EdgeInsets screenInsets =
      EdgeInsets.symmetric(horizontal: screenPadding, vertical: md);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardInsetsLg = EdgeInsets.all(cardPaddingLg);
  static const EdgeInsets listItemInsets =
      EdgeInsets.symmetric(horizontal: md, vertical: 12.0);
}
