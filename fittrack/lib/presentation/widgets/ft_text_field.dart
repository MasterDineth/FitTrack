import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable labeled text field matching the FitTrack Stitch design.
class FtTextField extends StatelessWidget {
  const FtTextField({
    super.key,
    required this.controller,
    required this.label,
    this.placeholder = '',
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String placeholder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.slate800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.slateDark,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.slate400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: prefixIcon,
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: suffixIcon,
            errorText: errorText,
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.slate400,
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.errorRed,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.kineticMint, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.errorRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
