import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: widget.isOutlined
            ? OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon != null ? Icon(widget.icon, size: 20) : null,
                label: Text(widget.label),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      widget.foregroundColor ??
                      Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color:
                        widget.foregroundColor ??
                        Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon != null ? Icon(widget.icon, size: 20) : null,
                label: Text(widget.label),
                style: widget.backgroundColor != null
                    ? ElevatedButton.styleFrom(
                        backgroundColor: widget.backgroundColor,
                        foregroundColor: widget.foregroundColor ?? Colors.white,
                      )
                    : null,
              ),
      ),
    );
  }
}
