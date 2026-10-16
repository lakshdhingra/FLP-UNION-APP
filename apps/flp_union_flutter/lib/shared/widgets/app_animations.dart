import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Smoothly counts up from 0 to [value] over [duration] using an easing curve.
class AnimatedCountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;

  const AnimatedCountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, val, child) {
        final formatted = '${prefix ?? ''}${val.round()}${suffix ?? ''}';
        return Text(formatted, style: style);
      },
    );
  }
}

/// Staggered slide-and-fade entrance for dashboard items and list cards.
class StaggeredSlideFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 380),
    this.slideOffset = const Offset(0, 0.08),
  });

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    final delay = widget.delayStep * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Subtle press-down scale effect (0.98) for cards and buttons.
class PressScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const PressScaleWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.98,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<PressScaleWrapper> createState() => _PressScaleWrapperState();
}

class _PressScaleWrapperState extends State<PressScaleWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// A smooth fade-through and subtle slide transition page for GoRouter
CustomTransitionPage<T> buildAppTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

/// A direction-aware, state-preserving animated container for shell branch navigators.
///
/// Smoothly transitions between navigation branches using a subtle slide (4.5% of width)
/// and opacity fade with [Curves.easeOutCubic] over 280ms, preserving all child state,
/// scroll positions, Riverpod subscriptions, and GoRouter history.
class AnimatedBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;
  final Duration duration;
  final double slideOffsetFactor;

  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 280),
    this.slideOffsetFactor = 0.045,
  });

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int _currentIndex = 0;
  int? _previousIndex;
  double _direction = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _previousIndex = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;

      _previousIndex = oldWidget.currentIndex;
      _currentIndex = widget.currentIndex;
      _direction = _currentIndex > _previousIndex! ? 1.0 : -1.0;

      if (disableAnimations) {
        _controller.value = 1.0;
        _previousIndex = null;
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final progress = _animation.value;

        return Stack(
          fit: StackFit.expand,
          children: List.generate(widget.children.length, (index) {
            final isCurrent = index == _currentIndex;
            final isPrevious = index == _previousIndex;

            final bool offstage = !isCurrent && !isPrevious;
            final bool enabled = isCurrent;
            final bool ignoring = !isCurrent;

            double opacity;
            Offset offset;

            if (isCurrent) {
              if (_previousIndex != null && _controller.isAnimating) {
                // Incoming child: slides in from (slideOffsetFactor * _direction) to 0, fades from 0 to 1
                offset = Offset(
                    widget.slideOffsetFactor * _direction * (1.0 - progress),
                    0.0);
                opacity = progress.clamp(0.0, 1.0);
              } else {
                offset = Offset.zero;
                opacity = 1.0;
              }
            } else if (isPrevious) {
              // Outgoing child: slides out from 0 to (-slideOffsetFactor * _direction), fades from 1 to 0
              offset = Offset(
                  -widget.slideOffsetFactor * _direction * progress, 0.0);
              opacity = (1.0 - progress).clamp(0.0, 1.0);
            } else {
              offset = Offset.zero;
              opacity = 1.0;
            }

            return KeyedSubtree(
              key: ValueKey<int>(index),
              child: Offstage(
                offstage: offstage,
                child: TickerMode(
                  enabled: enabled,
                  child: IgnorePointer(
                    ignoring: ignoring,
                    child: FractionalTranslation(
                      translation: offset,
                      child: Opacity(
                        opacity: opacity,
                        child: widget.children[index],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
