import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/password_validator.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wymagania dotyczące hasła',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            _Req(
              met: PasswordValidator.hasMinLength(password),
              label: 'Minimum 8 znaków',
            ),
            _Req(
              met: PasswordValidator.hasUppercase(password),
              label: 'Co najmniej 1 wielka litera (A–Z)',
            ),
            _Req(
              met: PasswordValidator.hasLowercase(password),
              label: 'Co najmniej 1 mała litera (a–z)',
            ),
            _Req(
              met: PasswordValidator.hasDigit(password),
              label: 'Co najmniej 1 cyfra (0–9)',
            ),
            _Req(
              met: PasswordValidator.hasSpecialChar(password),
              label: 'Co najmniej 1 znak specjalny (!@#\$%...)',
            ),
          ],
        ),
      ),
    );
  }
}

class _Req extends StatelessWidget {
  final bool met;
  final String label;

  const _Req({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(
            met
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: met ? const Color(0xFF16A34A) : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: met ? const Color(0xFF15803D) : AppColors.textSecondary,
              fontWeight: met ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
