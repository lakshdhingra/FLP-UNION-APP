import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppFontSize {
  static const double xs = 11.0;
  static const double sm = 13.0;
  static const double md = 15.0;
  static const double lg = 17.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 30.0;
}

abstract class AppFontWeight {
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

abstract class AppTypography {
  static const TextStyle xs = TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle sm = TextStyle(
    fontSize: AppFontSize.sm,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle md = TextStyle(
    fontSize: AppFontSize.md,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle lg = TextStyle(
    fontSize: AppFontSize.lg,
    fontWeight: AppFontWeight.semibold,
    color: AppColors.textPrimary,
  );

  static const TextStyle xl = TextStyle(
    fontSize: AppFontSize.xl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle xxl = TextStyle(
    fontSize: AppFontSize.xxl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle xxxl = TextStyle(
    fontSize: AppFontSize.xxxl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
  );
}
