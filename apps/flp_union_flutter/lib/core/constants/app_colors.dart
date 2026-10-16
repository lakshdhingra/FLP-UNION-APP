import 'package:flutter/material.dart';

/// Semantic colors for FLP Union matching the Apple × Linear × Enterprise design system.
abstract class AppColors {
  // Dark Palette (Default)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSecondarySurface = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardHover = Color(0xFF242426);
  static const Color darkCardPressed = Color(0xFF161618);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkBorderSubtle = Color(0xFF28282A);

  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF98989D);
  static const Color darkTextMuted = Color(0xFF636366);

  static const Color darkPrimaryAction = Color(0xFF0A84FF);
  static const Color darkPrimaryActionSubtle = Color(0xFF143055);
  static const Color darkSuccess = Color(0xFF30D158);
  static const Color darkSuccessBg = Color(0xFF0F3818);
  static const Color darkWarning = Color(0xFFFF9F0A);
  static const Color darkWarningBg = Color(0xFF3B2505);
  static const Color darkDanger = Color(0xFFFF453A);
  static const Color darkDangerBg = Color(0xFF3A1210);
  static const Color darkInfo = Color(0xFF64D2FF);
  static const Color darkInfoBg = Color(0xFF0C2B3E);

  // Light Palette
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF8F8FA);
  static const Color lightCardPressed = Color(0xFFEEEEF0);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightBorderSubtle = Color(0xFFEFEFF4);

  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  static const Color lightPrimaryAction = Color(0xFF007AFF);
  static const Color lightPrimaryActionSubtle = Color(0xFFEBF5FF);
  static const Color lightSuccess = Color(0xFF34C759);
  static const Color lightSuccessBg = Color(0xFFEBF9EE);
  static const Color lightWarning = Color(0xFFFF9500);
  static const Color lightWarningBg = Color(0xFFFFF6EB);
  static const Color lightDanger = Color(0xFFFF3B30);
  static const Color lightDangerBg = Color(0xFFFFEBEA);
  static const Color lightInfo = Color(0xFF007AFF);
  static const Color lightInfoBg = Color(0xFFEBF5FF);

  // Common static references for backward compatibility (defaults to dark mode values)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color secondarySurface = darkSecondarySurface;
  static const Color card = darkCard;
  static const Color cardHover = darkCardHover;
  static const Color cardPressed = darkCardPressed;
  static const Color border = darkBorder;
  static const Color borderSubtle = darkBorderSubtle;

  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;

  static const Color accent = darkPrimaryAction;
  static const Color accentHover = Color(0xFF0071E3);
  static const Color accentSubtle = darkPrimaryActionSubtle;

  static const Color success = darkSuccess;
  static const Color successBg = darkSuccessBg;
  static const Color warning = darkWarning;
  static const Color warningBg = darkWarningBg;
  static const Color danger = darkDanger;
  static const Color dangerBg = darkDangerBg;
  static const Color info = darkInfo;
  static const Color infoBg = darkInfoBg;

  static const Color overlay = Color(0x99000000);

  /// Helper to get context-aware theme colors
  static AppThemeColors of(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeColors>();
    if (ext != null) return ext;
    return Theme.of(context).brightness == Brightness.dark
        ? AppThemeColors.dark
        : AppThemeColors.light;
  }
}

/// ThemeExtension for semantic theme colors that update on theme switch
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color secondarySurface;
  final Color card;
  final Color cardHover;
  final Color cardPressed;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primaryAction;
  final Color primaryActionSubtle;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color dangerBg;
  final Color info;
  final Color infoBg;
  final Color overlay;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.secondarySurface,
    required this.card,
    required this.cardHover,
    required this.cardPressed,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryAction,
    required this.primaryActionSubtle,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.danger,
    required this.dangerBg,
    required this.info,
    required this.infoBg,
    required this.overlay,
  });

  static const dark = AppThemeColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    secondarySurface: AppColors.darkSecondarySurface,
    card: AppColors.darkCard,
    cardHover: AppColors.darkCardHover,
    cardPressed: AppColors.darkCardPressed,
    border: AppColors.darkBorder,
    borderSubtle: AppColors.darkBorderSubtle,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    primaryAction: AppColors.darkPrimaryAction,
    primaryActionSubtle: AppColors.darkPrimaryActionSubtle,
    success: AppColors.darkSuccess,
    successBg: AppColors.darkSuccessBg,
    warning: AppColors.darkWarning,
    warningBg: AppColors.darkWarningBg,
    danger: AppColors.darkDanger,
    dangerBg: AppColors.darkDangerBg,
    info: AppColors.darkInfo,
    infoBg: AppColors.darkInfoBg,
    overlay: Color(0x99000000),
  );

  static const light = AppThemeColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    secondarySurface: AppColors.lightSecondarySurface,
    card: AppColors.lightCard,
    cardHover: AppColors.lightCardHover,
    cardPressed: AppColors.lightCardPressed,
    border: AppColors.lightBorder,
    borderSubtle: AppColors.lightBorderSubtle,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    primaryAction: AppColors.lightPrimaryAction,
    primaryActionSubtle: AppColors.lightPrimaryActionSubtle,
    success: AppColors.lightSuccess,
    successBg: AppColors.lightSuccessBg,
    warning: AppColors.lightWarning,
    warningBg: AppColors.lightWarningBg,
    danger: AppColors.lightDanger,
    dangerBg: AppColors.lightDangerBg,
    info: AppColors.lightInfo,
    infoBg: AppColors.lightInfoBg,
    overlay: Color(0x33000000),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? secondarySurface,
    Color? card,
    Color? cardHover,
    Color? cardPressed,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primaryAction,
    Color? primaryActionSubtle,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? danger,
    Color? dangerBg,
    Color? info,
    Color? infoBg,
    Color? overlay,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      card: card ?? this.card,
      cardHover: cardHover ?? this.cardHover,
      cardPressed: cardPressed ?? this.cardPressed,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryAction: primaryAction ?? this.primaryAction,
      primaryActionSubtle: primaryActionSubtle ?? this.primaryActionSubtle,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      secondarySurface:
          Color.lerp(secondarySurface, other.secondarySurface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardHover: Color.lerp(cardHover, other.cardHover, t)!,
      cardPressed: Color.lerp(cardPressed, other.cardPressed, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      primaryActionSubtle:
          Color.lerp(primaryActionSubtle, other.primaryActionSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppColors.of(this);
}
