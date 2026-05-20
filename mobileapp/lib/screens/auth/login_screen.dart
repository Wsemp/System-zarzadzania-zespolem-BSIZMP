import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/auth/token_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_clipper.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await TokenStorage.getSavedCredentials();
    if (creds != null && mounted) {
      setState(() {
        _userCtrl.text = creds['username']!;
        _passCtrl.text = creds['password']!;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.login(
        _userCtrl.text.trim(),
        _passCtrl.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      if (ok) {
        if (_rememberMe) {
          await TokenStorage.saveCredentials(
            _userCtrl.text.trim(),
            _passCtrl.text,
          );
        } else {
          await TokenStorage.clearCredentials();
        }
        context.go('/home');
      } else {
        setState(() => _error = auth.error ?? 'Nieprawidłowe dane logowania');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(
      text: _userCtrl.text.contains('@') ? _userCtrl.text : '',
    );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ForgotPasswordDialog(
        emailCtrl: emailCtrl,
        onSend: (email) async {
          final auth = context.read<AuthProvider>();
          return auth.forgotPassword(email);
        },
      ),
    );
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
          'Logowanie przez $platform będzie dostępne w kolejnej wersji aplikacji. Zapraszamy wkrótce!',
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
    final headerH = screenH * 0.20;
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
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Witaj ponownie',
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
                            'Zaloguj się na swoje konto',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 56),
                          if (_error != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
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
                          const SizedBox(height: 16),
                          _shadowField(
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: _inputDeco(
                                'Hasło',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Pole wymagane' : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: const Color(0xFF7C5CFC),
                                  side: const BorderSide(
                                    color: Color(0xFFCCCCCC),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Zapamiętaj mnie',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: Text(
                                  'Zapomniałeś hasła?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF7C5CFC),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
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
                              onPressed: _loading ? null : _login,
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
                                      'Zaloguj się',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SocialDivider(label: 'lub zaloguj przez'),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Nie masz konta? ',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: Text(
                                  'Zarejestruj się',
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

class _ForgotPasswordDialog extends StatefulWidget {
  final TextEditingController emailCtrl;
  final Future<String?> Function(String email) onSend;

  const _ForgotPasswordDialog({required this.emailCtrl, required this.onSend});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  bool _sending = false;
  bool _sent = false;
  String? _error;

  Future<void> _send() async {
    final email = widget.emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Podaj prawidłowy adres e-mail');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final error = await widget.onSend(email);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (error == null) {
        _sent = true;
      } else {
        _error = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Resetuj hasło',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
      ),
      content: _sent
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: Color(0xFF7C5CFC),
                ),
                const SizedBox(height: 12),
                Text(
                  'Link do resetowania hasła został wysłany na adres:\n${widget.emailCtrl.text.trim()}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Podaj swój adres e-mail, a wyślemy Ci link do resetowania hasła.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Adres e-mail',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C5CFC),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
      actions: _sent
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF7C5CFC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Anuluj',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF7C5CFC),
                        ),
                      )
                    : Text(
                        'Wyślij',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF7C5CFC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
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
