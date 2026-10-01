import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  });

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.sm.copyWith(
              fontWeight: AppFontWeight.medium,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: widget.error != null ? AppColors.danger : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword ? _obscureText : false,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  maxLines: widget.isPassword ? 1 : (widget.multiline ? widget.maxLines ?? 4 : 1),
                  style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.md.copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
            ],
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.error!,
            style: AppTypography.xs.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
