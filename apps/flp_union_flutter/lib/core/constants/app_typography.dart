import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppFontSize {
  static const double xxs = 10.0;
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
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

abstract class AppTypography {
  // Base font getter with Inter
  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Backward compatible static styles
  static const TextStyle xs = TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: -0.1,
  );

  static const TextStyle sm = TextStyle(
    fontSize: AppFontSize.sm,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: -0.15,
  );

  static const TextStyle md = TextStyle(
    fontSize: AppFontSize.md,
    fontWeight: AppFontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle lg = TextStyle(
    fontSize: AppFontSize.lg,
    fontWeight: AppFontWeight.semibold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle xl = TextStyle(
    fontSize: AppFontSize.xl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const TextStyle xxl = TextStyle(
    fontSize: AppFontSize.xxl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle xxxl = TextStyle(
    fontSize: AppFontSize.xxxl,
    fontWeight: AppFontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
  );

  // Modern Apple/Linear Hierarchy
  static TextStyle display({Color? color}) => font(
        fontSize: 32,
        fontWeight: AppFontWeight.bold,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      );

  static TextStyle title1({Color? color}) => font(
        fontSize: 24,
        fontWeight: AppFontWeight.bold,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.6,
        height: 1.25,
      );

  static TextStyle title2({Color? color}) => font(
        fontSize: 20,
        fontWeight: AppFontWeight.semibold,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      );

  static TextStyle title3({Color? color}) => font(
        fontSize: 17,
        fontWeight: AppFontWeight.semibold,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle body({Color? color, FontWeight? weight}) => font(
        fontSize: 15,
        fontWeight: weight ?? AppFontWeight.normal,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.45,
      );

  static TextStyle subhead({Color? color, FontWeight? weight}) => font(
        fontSize: 13,
        fontWeight: weight ?? AppFontWeight.normal,
        color: color ?? AppColors.textSecondary,
        letterSpacing: -0.1,
        height: 1.4,
      );

  static TextStyle caption({Color? color, FontWeight? weight}) => font(
        fontSize: 12,
        fontWeight: weight ?? AppFontWeight.medium,
        color: color ?? AppColors.textMuted,
        letterSpacing: 0,
        height: 1.35,
      );

  static TextStyle label({Color? color}) => font(
        fontSize: 11,
        fontWeight: AppFontWeight.semibold,
        color: color ?? AppColors.textMuted,
        letterSpacing: 0.4,
      );
}
