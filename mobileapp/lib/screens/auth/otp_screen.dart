import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class OtpScreen extends StatefulWidget {
  final String? contact;
  const OtpScreen({super.key, this.contact});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _ctrl = TextEditingController();
  String _otp = '';
  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wprowadź pełny 6-cyfrowy kod')),
      );
      return;
    }
    setState(() => _loading = true);

    // TODO: zaimplementować wywołanie API po stronie backendu
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/projects');
  }

  void _resend() {
    _startCountdown();
    // TODO: wywołać endpoint ponownego wysłania kodu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kod wysłany ponownie'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Weryfikacja 2FA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.contact != null
                    ? 'Wprowadź kod wysłany na\n${widget.contact}'
                    : 'Wprowadź 6-cyfrowy kod weryfikacyjny',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                controller: _ctrl,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                animationDuration: const Duration(milliseconds: 200),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 46,
                  activeFillColor: Colors.white,
                  inactiveFillColor: AppColors.background,
                  selectedFillColor: Colors.white,
                  activeColor: AppColors.purple,
                  inactiveColor: AppColors.divider,
                  selectedColor: AppColors.purple,
                ),
                enableActiveFill: true,
                onChanged: (val) => setState(() => _otp = val),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Zweryfikuj',
                onPressed: _loading ? null : _verify,
                isLoading: _loading,
              ),
              const SizedBox(height: 24),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Wyślij kod ponownie za ${_secondsLeft}s',
                        style: const TextStyle(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text(
                          'Wyślij kod ponownie',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔒  2FA – wersja demonstracyjna',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
