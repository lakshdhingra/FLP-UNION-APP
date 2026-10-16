import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const AppSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = AppRadius.borderFull;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: colors.secondarySurface,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }
}

/// Skeletons for cards and lists
class AppSkeletonCard extends StatelessWidget {
  final double height;

  const AppSkeletonCard({super.key, this.height = 76.0});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: const Row(
        children: [
          AppSkeleton.circle(size: 44),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSkeleton(width: 140, height: 14),
                SizedBox(height: 8),
                AppSkeleton(width: 90, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  final int count;
  final double cardHeight;

  const AppSkeletonList({
    super.key,
    this.count = 5,
    this.cardHeight = 76.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => AppSkeletonCard(height: cardHeight),
    );
  }
}

class AppDashboardSkeleton extends StatelessWidget {
  const AppDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header profile skeleton
          AppSkeletonCard(height: 88),
          SizedBox(height: AppSpacing.lg),
          // Metric cards row skeleton
          Row(
            children: [
              Expanded(
                  child: AppSkeleton(
                      width: double.infinity,
                      height: 86,
                      borderRadius: AppRadius.cardRadius)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: AppSkeleton(
                      width: double.infinity,
                      height: 86,
                      borderRadius: AppRadius.cardRadius)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: AppSkeleton(
                      width: double.infinity,
                      height: 86,
                      borderRadius: AppRadius.cardRadius)),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppSkeleton(width: 120, height: 16),
          SizedBox(height: AppSpacing.sm),
          AppSkeletonCard(height: 140),
        ],
      ),
    );
  }
}

class AppDetailSkeleton extends StatelessWidget {
  const AppDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: colors.border, width: 1),
            ),
            child: const Column(
              children: [
                Center(child: AppSkeleton.circle(size: 72)),
                SizedBox(height: AppSpacing.md),
                AppSkeleton(width: 160, height: 18),
                SizedBox(height: 8),
                AppSkeleton(width: 110, height: 12),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSkeleton(width: 70, height: 20),
                    SizedBox(width: 8),
                    AppSkeleton(width: 90, height: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppSkeletonCard(height: 120),
          const SizedBox(height: AppSpacing.md),
          const AppSkeletonCard(height: 140),
        ],
      ),
    );
  }
}
