import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_clipper.dart';
import '../../widgets/password_requirements.dart';
import '../../widgets/social_circle_button.dart';

const _kHeaderGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [Color(0xFFFF8A3D), Color(0xFFCB8BE8), Color(0xFF7C5CFC)],
  stops: [0.0, 0.55, 1.0],
);

const _kButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFFF8A3D), Color(0xFF7C5CFC)],
);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  bool get _hasUpper => _passCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passCtrl.text.contains(RegExp(r'\d'));
  bool get _hasMin => _passCtrl.text.length >= 8;
  bool get _passwordsMatch =>
      _passCtrl.text == _confirmCtrl.text && _confirmCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_passwordsMatch) {
      setState(() => _error = 'Hasła nie są identyczne');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.register(
        _userCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        setState(() => _error = auth.error ?? 'Błąd rejestracji');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showComingSoon(String platform) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Wkrótce dostępne',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Rejestracja przez $platform będzie dostępna w kolejnej wersji aplikacji. Zapraszamy wkrótce!',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7C5CFC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7C5CFC), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }

  Widget _shadowField(Widget field) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: field,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final headerH = screenH * 0.18;
    const overlap = 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerH,
            child: _AuthHeader(
              height: headerH,
              onBack: () => context.go('/welcome'),
            ),
          ),
          Column(
            children: [
              SizedBox(height: headerH - overlap),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Stwórz konto',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dołącz do Taskomat już dziś',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          if (_error != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          _shadowField(
                            TextFormField(
                              controller: _userCtrl,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: _inputDeco(
                                'Nazwa użytkownika',
                                Icons.person_outline_rounded,
                              ),
                              validator: (v) => (v?.trim().isEmpty ?? true)
                                  ? 'Pole wymagane'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _shadowField(
                            TextFormField(
                              controller: _emailCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: _inputDeco(
                                'Adres e-mail',
                                Icons.email_outlined,
                              ),
                              validator: (v) {
                                if (v?.trim().isEmpty ?? true) {
                                  return 'Pole wymagane';
                                }
                                if (!v!.contains('@')) {
                                  return 'Nieprawidłowy e-mail';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          _shadowField(
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: _inputDeco(
                                'Hasło',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v?.isEmpty ?? true) {
                                  return 'Pole wymagane';
                                }
                                if (!_hasMin) {
                                  return 'Min. 8 znaków';
                                }
                                return null;
                              },
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _passCtrl.text.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: PasswordRequirements(
                                      password: _passCtrl.text,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 14),
                          _shadowField(
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => setState(() {}),
                              onFieldSubmitted: (_) => _register(),
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: _inputDeco(
                                'Potwierdź hasło',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Pole wymagane' : null,
                            ),
                          ),
                          if (_confirmCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _passwordsMatch
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 14,
                                  color: _passwordsMatch
                                      ? AppColors.success
                                      : Colors.red.shade400,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _passwordsMatch
                                      ? 'Hasła są zgodne'
                                      : 'Hasła nie są zgodne',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _passwordsMatch
                                        ? AppColors.success
                                        : Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: _kButtonGradient,
                              borderRadius: BorderRadius.circular(27),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C5CFC,
                                  ).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Zarejestruj się',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SocialDivider(label: 'lub zarejestruj przez'),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialCircleButton.facebook(
                                onTap: () => _showComingSoon('Facebook'),
                              ),
                              const SizedBox(width: 24),
                              SocialCircleButton.google(
                                onTap: () => _showComingSoon('Google'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masz już konto? ',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Zaloguj się',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF7C5CFC),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final double height;
  final VoidCallback onBack;

  const _AuthHeader({required this.height, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: const BoxDecoration(gradient: _kHeaderGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: AuthWavePainter(color: Colors.white.withOpacity(0.12)),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  final String label;
  const _SocialDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8E8F2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8E8F2))),
      ],
    );
  }
}
