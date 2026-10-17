import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppMultiSelect extends StatelessWidget {
  final String? label;
  final String placeholder;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final Widget? prefixIcon;
  final String? error;
  final String dialogTitle;
  final bool allowCustom;
  final String customOptionLabel;

  const AppMultiSelect({
    super.key,
    this.label,
    this.placeholder = 'Select options...',
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.prefixIcon,
    this.error,
    this.dialogTitle = 'Select Options',
    this.allowCustom = false,
    this.customOptionLabel = 'Other',
  });

  void _openSelectionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MultiSelectSheet(
        title: dialogTitle,
        options: options,
        initialSelected: selectedValues,
        onChanged: onChanged,
        allowCustom: allowCustom,
        customOptionLabel: customOptionLabel,
      ),
    );
  }

  void _removeValue(String val) {
    final updated = List<String>.from(selectedValues)..remove(val);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.subhead(
              color: colors.textSecondary,
              weight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: () => _openSelectionSheet(context),
          borderRadius: AppRadius.inputRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: AppRadius.inputRadius,
              border: Border.all(
                color: hasError ? colors.danger : colors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selectedValues.isEmpty
                        ? placeholder
                        : '${selectedValues.length} selected',
                    style: AppTypography.body(
                      color: selectedValues.isEmpty
                          ? colors.textMuted
                          : colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
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
                  error!,
                  style: AppTypography.caption(color: colors.danger),
                ),
              ),
            ],
          ),
        ],
        if (selectedValues.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedValues.map((item) {
              return Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 6, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: colors.secondarySurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item,
                        style: AppTypography.caption(
                          color: colors.textPrimary,
                          weight: AppFontWeight.medium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _removeValue(item),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          LucideIcons.x,
                          size: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onChanged;
  final bool allowCustom;
  final String customOptionLabel;

  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
    required this.onChanged,
    required this.allowCustom,
    required this.customOptionLabel,
  });

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final List<String> _selected;
  final _searchController = TextEditingController();
  final _customInputController = TextEditingController();
  String _search = '';
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
    widget.onChanged(_selected);
  }

  void _addCustomOption() {
    final text = _customInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (!_selected.contains(text)) {
        _selected.add(text);
      }
      _customInputController.clear();
      _showCustomInput = false;
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Merge predefined options with any custom options already selected
    final allOptions = Set<String>.from(widget.options);
    allOptions.addAll(_selected);

    final filtered = allOptions.where((opt) {
      if (_search.isEmpty) return true;
      return opt.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.75,
      ),
      margin: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.title2(color: colors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primaryAction,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.body(
                        color: colors.primaryAction,
                        weight: AppFontWeight.semibold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.secondarySurface,
                  borderRadius: AppRadius.inputRadius,
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _search = val.trim()),
                  style: AppTypography.body(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search options...',
                    hintStyle: AppTypography.body(color: colors.textMuted),
                    prefixIcon: Icon(LucideIcons.search,
                        size: 16, color: colors.textMuted),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x,
                                size: 14, color: colors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: colors.border.withAlpha(50)),
                itemBuilder: (ctx, idx) {
                  final opt = filtered[idx];
                  final isSelected = _selected.contains(opt);

                  return InkWell(
                    onTap: () => _toggleOption(opt),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primaryAction
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primaryAction
                                    : colors.border,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt,
                              style: AppTypography.body(
                                color: isSelected
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                                weight: isSelected
                                    ? AppFontWeight.semibold
                                    : AppFontWeight.regular,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.allowCustom) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: _showCustomInput
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customInputController,
                              style:
                                  AppTypography.body(color: colors.textPrimary),
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Please specify other...',
                                hintStyle:
                                    AppTypography.body(color: colors.textMuted),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.inputRadius,
                                  borderSide:
                                      BorderSide(color: colors.primaryAction),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addCustomOption(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(LucideIcons.check,
                                color: colors.primaryAction),
                            onPressed: _addCustomOption,
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.x, color: colors.textMuted),
                            onPressed: () =>
                                setState(() => _showCustomInput = false),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () =>
                            setState(() => _showCustomInput = true),
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: Text(
                          'Add ${widget.customOptionLabel}',
                          style: AppTypography.body(
                            color: colors.primaryAction,
                            weight: AppFontWeight.medium,
                          ),
                        ),
                      ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
