import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_typography.dart';

abstract class AppTheme {
  /// Dark Theme (Default)
  static ThemeData get darkTheme {
    const colors = AppThemeColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      extensions: const [colors],
      colorScheme: ColorScheme.dark(
        primary: colors.primaryAction,
        secondary: colors.primaryActionSubtle,
        surface: colors.surface,
        error: colors.danger,
        onPrimary: colors.textPrimary,
        onSecondary: colors.textPrimary,
        onSurface: colors.textPrimary,
        onError: colors.textPrimary,
        outline: colors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title3(color: colors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 20),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body(color: colors.textMuted),
        labelStyle: AppTypography.subhead(
            color: colors.textSecondary, weight: AppFontWeight.medium),
        errorStyle: AppTypography.caption(color: colors.danger),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryAction,
          foregroundColor: colors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius),
          textStyle: AppTypography.body(
              color: colors.textPrimary, weight: AppFontWeight.semibold),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primaryAction,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(weight: AppFontWeight.medium),
        unselectedLabelStyle:
            AppTypography.caption(weight: AppFontWeight.normal),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        titleTextStyle: AppTypography.title2(color: colors.textPrimary),
        contentTextStyle: AppTypography.body(color: colors.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        elevation: 8,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        modalBackgroundColor: colors.card,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.card,
        contentTextStyle: AppTypography.subhead(color: colors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.inputRadius,
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    const colors = AppThemeColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      extensions: const [colors],
      colorScheme: ColorScheme.light(
        primary: colors.primaryAction,
        secondary: colors.primaryActionSubtle,
        surface: colors.surface,
        error: colors.danger,
        onPrimary: Colors.white,
        onSecondary: colors.textPrimary,
        onSurface: colors.textPrimary,
        onError: Colors.white,
        outline: colors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title3(color: colors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 20),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body(color: colors.textMuted),
        labelStyle: AppTypography.subhead(
            color: colors.textSecondary, weight: AppFontWeight.medium),
        errorStyle: AppTypography.caption(color: colors.danger),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryAction,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius),
          textStyle: AppTypography.body(
              color: Colors.white, weight: AppFontWeight.semibold),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primaryAction,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(weight: AppFontWeight.medium),
        unselectedLabelStyle:
            AppTypography.caption(weight: AppFontWeight.normal),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        titleTextStyle: AppTypography.title2(color: colors.textPrimary),
        contentTextStyle: AppTypography.body(color: colors.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        elevation: 8,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        modalBackgroundColor: colors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: AppTypography.subhead(color: colors.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.inputRadius,
        ),
      ),
    );
  }
}
