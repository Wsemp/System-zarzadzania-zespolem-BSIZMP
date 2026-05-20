import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/password_validator.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wymagania hasła',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            _RequirementRow(
              met: PasswordValidator.hasMinLength(password),
              label: 'Minimum 8 znaków',
            ),
            _RequirementRow(
              met: PasswordValidator.hasUppercase(password),
              label: 'Co najmniej 1 wielka litera (A–Z)',
            ),
            _RequirementRow(
              met: PasswordValidator.hasLowercase(password),
              label: 'Co najmniej 1 mała litera (a–z)',
            ),
            _RequirementRow(
              met: PasswordValidator.hasDigit(password),
              label: 'Co najmniej 1 cyfra (0–9)',
            ),
            _RequirementRow(
              met: PasswordValidator.hasSpecialChar(password),
              label: 'Co najmniej 1 znak specjalny (!@#\$%...)',
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;

  const _RequirementRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: met ? const Color(0xFF16A34A) : AppColors.textSecondary,
          fontWeight: met ? FontWeight.w500 : FontWeight.w400,
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                met
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(met),
                size: 16,
                color: met ? const Color(0xFF16A34A) : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
