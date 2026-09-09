import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable primary CTA button with kinetic-mint gradient and glow shadow.
class FtPrimaryButton extends StatefulWidget {
  const FtPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.width = double.infinity,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? trailingIcon;
  final double width;
  final double height;

  @override
  State<FtPrimaryButton> createState() => _FtPrimaryButtonState();
}

class _FtPrimaryButtonState extends State<FtPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.kineticMint, Color(0xFF00F0A0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.kineticMint.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.slateDark),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppColors.slateDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      widget.trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
