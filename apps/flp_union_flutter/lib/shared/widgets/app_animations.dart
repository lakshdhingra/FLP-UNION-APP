import 'package:flutter/material.dart';

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
