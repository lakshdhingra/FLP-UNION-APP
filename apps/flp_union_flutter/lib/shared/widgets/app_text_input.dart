import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppTextInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? error;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool multiline;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;

  const AppTextInput({
    super.key,
    this.label,
    this.placeholder,
    this.error,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.multiline = false,
    this.maxLines,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
  });

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  bool _obscureText = true;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    Color borderColor = colors.border;
    double borderWidth = 1.0;

    if (hasError) {
      borderColor = colors.danger;
      borderWidth = 1.2;
    } else if (_isFocused) {
      borderColor = colors.primaryAction;
      borderWidth = 1.5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.subhead(
              color: colors.textSecondary,
              weight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: AppRadius.inputRadius,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (hasError ? colors.danger : colors.primaryAction)
                          .withAlpha(28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: widget.multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 4),
                  child: widget.prefixIcon,
                ),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword ? _obscureText : false,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  maxLines: widget.isPassword
                      ? 1
                      : (widget.multiline ? widget.maxLines ?? 4 : 1),
                  style: AppTypography.body(color: colors.textPrimary),
                  cursorColor: colors.primaryAction,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.body(color: colors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 16,
                      vertical: widget.multiline ? 14 : 14,
                    ),
                  ),
                ),
              ),
              if (widget.showClearButton &&
                  widget.controller != null &&
                  widget.controller!.text.isNotEmpty)
                IconButton(
                  icon: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
                  onPressed: () {
                    widget.controller!.clear();
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                ),
              if (widget.isPassword)
                IconButton(
                  splashRadius: 18,
                  icon: Icon(
                    _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              if (widget.suffixIcon != null && !widget.isPassword)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: widget.suffixIcon,
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(LucideIcons.alertCircle, size: 13, color: colors.danger),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.error!,
                  style: AppTypography.caption(
                    color: colors.danger,
                    weight: AppFontWeight.medium,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
