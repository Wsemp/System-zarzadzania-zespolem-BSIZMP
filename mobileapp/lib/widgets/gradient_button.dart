import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ??
        (onPressed != null
            ? AppColors.gradientPurple
            : const LinearGradient(colors: [Colors.grey, Colors.grey]));

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class OrangeGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const OrangeGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      gradient: AppColors.gradientOrange,
    );
  }
}
