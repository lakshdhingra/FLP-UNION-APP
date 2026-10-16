import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppSearchInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final VoidCallback? onClear;

  const AppSearchInput({
    super.key,
    this.controller,
    this.onChanged,
    this.placeholder = 'Search...',
    this.onClear,
  });

  @override
  State<AppSearchInput> createState() => _AppSearchInputState();
}

class _AppSearchInputState extends State<AppSearchInput> {
  late final TextEditingController _internalController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _hasText = _internalController.text.isNotEmpty;
    _internalController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasNow = _internalController.text.isNotEmpty;
    if (hasNow != _hasText && mounted) {
      setState(() => _hasText = hasNow);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    } else {
      _internalController.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _handleClear() {
    _internalController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.inputRadius,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 16, color: colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _internalController,
              onChanged: widget.onChanged,
              style: AppTypography.body(color: colors.textPrimary),
              cursorColor: colors.primaryAction,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppTypography.body(color: colors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _handleClear,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.secondarySurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    Icon(LucideIcons.x, size: 12, color: colors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
