import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

/// A skeleton loader that mimics the exact layout proportions of [MatchCard].
///
/// Features:
/// - Shimmer animation sweeping across placeholder shapes
/// - Left accent bar placeholder
/// - League header row (emoji box + text + flag)
/// - Two team columns with circular avatar placeholders and text lines
/// - Central score area with digit placeholders
/// - Status badge placeholder
/// - Matches the exact card dimensions, padding, and border radius
///
/// Usage:
/// ```dart
/// MatchCardSkeleton()                        // single skeleton card
/// ListSkeleton(itemCount: 5)                 // 5 skeleton cards
/// ListSkeleton(itemCount: 3, itemBuilder: (i) => CustomSkeleton())
/// ```
class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  /// Override base color for the shimmer effect.
  final Color? baseColor;

  /// Override highlight color for the shimmer effect.
  final Color? highlightColor;

  Color get _baseColor => baseColor ?? AppColors.surfaceLighter;
  Color get _highlightColor => highlightColor ?? AppColors.surfaceLight;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _baseColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _highlightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League header skeleton
                  Row(
                    children: [
                      // Sport emoji box
                      _rect(24, 24, radius: 6),
                      const SizedBox(width: 8),
                      // League name
                      _rect(140, 14),
                      const Spacer(),
                      // Flag indicator
                      _rect(18, 13, radius: 2),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Teams + Score row
                  Row(
                    children: [
                      // Home team column
                      Expanded(
                        child: Column(
                          children: [
                            _circle(40),
                            const SizedBox(height: 8),
                            _rect(80, 14),
                            const SizedBox(height: 4),
                            _rect(50, 10),
                          ],
                        ),
                      ),

                      // Center column
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            // Status badge
                            _rect(40, 16, radius: 6),
                            const SizedBox(height: 8),
                            // Score
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _rect(28, 32, radius: 4),
                                const SizedBox(width: 8),
                                _rect(8, 20, radius: 4),
                                const SizedBox(width: 8),
                                _rect(28, 32, radius: 4),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Elapsed time / countdown
                            _rect(50, 12, radius: 4),
                          ],
                        ),
                      ),

                      // Away team column
                      Expanded(
                        child: Column(
                          children: [
                            _circle(40),
                            const SizedBox(height: 8),
                            _rect(80, 14),
                            const SizedBox(height: 4),
                            _rect(50, 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rect(double width, double height, {double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _circle(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: _baseColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Displays a list of skeleton items to represent loading content.
///
/// Use [MatchCardSkeleton] as the default item, or provide a custom
/// [itemBuilder] for other skeleton shapes.
///
/// Usage:
/// ```dart
/// // Default match card skeletons
/// ListSkeleton(itemCount: 6)
///
/// // Custom skeleton items
/// ListSkeleton(
///   itemCount: 4,
///   itemBuilder: (context, index) => MyCustomSkeleton(),
/// )
/// ```
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.baseColor,
    this.highlightColor,
  });

  /// Number of skeleton items to display.
  final int itemCount;

  /// Optional custom builder for each skeleton item.
  ///
  /// If `null`, defaults to [MatchCardSkeleton].
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Override base shimmer color (passed to default items).
  final Color? baseColor;

  /// Override highlight shimmer color (passed to default items).
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (itemBuilder != null) {
            return itemBuilder!(context, index);
          }
          return MatchCardSkeleton(
            baseColor: baseColor,
            highlightColor: highlightColor,
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// A simple shimmer text placeholder for inline loading states.
///
/// Usage:
/// ```dart
/// ShimmerText(width: 120, height: 16)
/// ```
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 4,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLighter,
      highlightColor: AppColors.surfaceLight,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLighter,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A shimmer placeholder that mimics a horizontal sport selector bar.
///
/// Usage:
/// ```dart
/// SportSelectorSkeleton()
/// ```
class SportSelectorSkeleton extends StatelessWidget {
  const SportSelectorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLighter,
      highlightColor: AppColors.surfaceLight,
      period: const Duration(milliseconds: 1500),
      child: SizedBox(
        height: 58,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 7, // "All" + 6 sports
          itemBuilder: (context, index) {
            return Container(
              width: 72,
              height: 42,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
