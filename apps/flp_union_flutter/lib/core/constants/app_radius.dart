import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0; // Input & button default: 12
  static const double lg = 16.0; // Card default: 16
  static const double xl = 20.0; // Dialog/sheet: 20
  static const double full = 9999.0;

  // Semantic tokens
  static const double button = 12.0;
  static const double input = 12.0;
  static const double card = 16.0;
  static const double cardSm = 12.0;
  static const double badge = 9999.0;
  static const double sheet = 20.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull =
      BorderRadius.all(Radius.circular(full));

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputRadius =
      BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(sheet));
}
