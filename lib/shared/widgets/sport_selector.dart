import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_config.dart';
import '../../core/models/sport_type.dart';

/// A horizontal scrollable sport selector with animated selection indicator.
///
/// Features:
/// - "All" option followed by each sport with its emoji icon
/// - Selected item shows a filled pill with sport accent color
/// - Unselected items are subtle with muted text
/// - Smooth horizontal scroll physics
/// - Animated selection transitions (scale + color)
/// - [onSelected] callback emits `null` for "All" or the selected [SportType]
///
/// Usage:
/// ```dart
/// SportSelector(
///   selected: SportType.football,
///   onSelected: (sport) => setState(() => _selected = sport),
/// )
/// ```
class SportSelector extends StatefulWidget {
  const SportSelector({
    super.key,
    this.selected,
    required this.onSelected,
    this.scrollController,
    this.height = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// Currently selected sport type, or `null` for "All".
  final SportType? selected;

  /// Callback when a sport (or "All") is tapped.
  final ValueChanged<SportType?> onSelected;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// Height of each pill item.
  final double height;

  /// Horizontal padding around the entire selector.
  final EdgeInsets padding;

  @override
  State<SportSelector> createState() => _SportSelectorState();
}

class _SportSelectorState extends State<SportSelector> {
  late final ScrollController _internalController;
  ScrollController get _controller => widget.scrollController ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _internalController = ScrollController();
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    if (!_controller.hasClients) return;

    // Each item is roughly 80px wide with 8px gap.
    const double itemWidth = 80.0;
    final targetOffset = (index * (itemWidth + 8)) - (_controller.position.viewportDimension / 2) + (itemWidth / 2);

    _controller.animateTo(
      targetOffset.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 16,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: widget.padding.left,
          right: widget.padding.right,
          top: 8,
          bottom: 8,
        ),
        itemCount: SportType.values.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          // Index 0 = "All", 1..6 = SportType.values
          final isAll = index == 0;
          final sport = isAll ? null : SportType.values[index - 1];
          final isSelected = widget.selected == sport;

          if (isAll) {
            return _buildPill(
              label: 'All',
              emoji: '🏆',
              isSelected: isSelected,
              accentColor: AppColors.textPrimary,
              onTap: () {
                widget.onSelected(null);
              },
            );
          }

          final accentColor = SportConfig.accentColor(sport!);
          return _buildPill(
            label: sport.shortName,
            emoji: sport.emoji,
            isSelected: isSelected,
            accentColor: accentColor,
            onTap: () {
              widget.onSelected(sport);
              _scrollToSelected(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required String emoji,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final Widget child = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.18)
              : AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : AppColors.glassBorder.withValues(alpha: 0.5),
            width: isSelected ? 1.0 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji icon
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 16 : 14,
              ),
            ),
            const SizedBox(width: 6),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: isSelected
                  ? AppTextStyles.labelMedium.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    )
                  : AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );

    return child.animate(
      key: ValueKey('${label}_$isSelected'),
    ).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: 200.ms,
      curve: Curves.easeOutBack,
    );
  }
}
