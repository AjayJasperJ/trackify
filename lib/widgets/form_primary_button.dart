import 'package:flutter/material.dart';

/// Shared sticky primary action button used at the bottom of every
/// add/edit form screen (task, goal, milestone).
class FormPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? primaryColor;
  final Color? onPrimaryColor;

  const FormPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor,
    this.onPrimaryColor,
  });

  @override
  State<FormPrimaryButton> createState() => _FormPrimaryButtonState();
}

class _FormPrimaryButtonState extends State<FormPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    final onPrimary = widget.onPrimaryColor ?? Theme.of(context).colorScheme.onPrimary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isPressed
                ? primary.withValues(alpha: 0.9)
                : primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
