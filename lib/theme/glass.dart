import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// Text helper matching Kotlin `T(s, size, w, color, lines, align)`
class T extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final int maxLines;
  final TextAlign? align;

  const T(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.normal,
    this.color = Colors.white,
    this.maxLines = 1,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: size,
        fontWeight: weight,
        color: color,
        decoration: TextDecoration.none,
      ),
    );
  }
}

/// Aesthetic Minimalist Focus Surface for Android TV remote & touch
class Glass extends StatefulWidget {
  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback? onClick;
  final VoidCallback? onLongClick;
  final BorderRadius borderRadius;
  final bool solidOnFocus;
  final double focusScale;
  final double baseOpacity;
  final FocusNode? focusNode;
  final bool autofocus;

  const Glass({
    super.key,
    required this.builder,
    this.onClick,
    this.onLongClick,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.solidOnFocus = false,
    this.focusScale = 1.05,
    this.baseOpacity = 0.85,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<Glass> createState() => _GlassState();
}

class _GlassState extends State<Glass> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  bool _focused = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.focusScale).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _node.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted && _node.hasFocus != _focused) {
      setState(() {
        _focused = _node.hasFocus;
      });
      if (_focused) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (_focused && widget.solidOnFocus) {
      bg = iosBlue;
    } else if (_focused) {
      bg = const Color(0xFF1B2130);
    } else {
      bg = aestheticSurface.withOpacity(widget.baseOpacity);
    }

    final border = Border.all(
      color: _focused ? iosBlue : aestheticBorder,
      width: _focused ? 2.0 : 1.0,
    );

    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            widget.onClick?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onClick,
        onLongPress: widget.onLongClick,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius,
                  color: bg,
                  border: border,
                  boxShadow: _focused
                      ? [
                          BoxShadow(
                            color: iosBlue.withOpacity(0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: widget.builder(context, _focused),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class RoundBtn extends StatelessWidget {
  final VoidCallback onClick;
  final Widget Function(Color color) icon;
  final FocusNode? focusNode;

  const RoundBtn({
    super.key,
    required this.onClick,
    required this.icon,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Glass(
        focusNode: focusNode,
        borderRadius: BorderRadius.circular(30),
        solidOnFocus: true,
        focusScale: 1.1,
        onClick: onClick,
        builder: (context, focused) {
          return Center(
            child: icon(focused ? Colors.black : Colors.white),
          );
        },
      ),
    );
  }
}
