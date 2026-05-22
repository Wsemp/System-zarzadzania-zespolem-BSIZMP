import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/password_validator.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_requirements.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _newPasswordValue = '';
  String _confirmValue = '';
  bool _saving = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.changePassword(
        oldPassword: _oldCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasło zostało zmienione'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } on ValidationException catch (e) {
      if (!mounted) return;
      final raw = e.message.toLowerCase();
      final msg =
          raw.contains('old_password') ||
              raw.contains('current') ||
              raw.contains('wrong') ||
              raw.contains('incorrect') ||
              raw.contains('invalid')
          ? 'Nieprawidłowe aktualne hasło'
          : e.message;
      _showError(msg);
    } on ForbiddenException catch (_) {
      if (!mounted) return;
      _showError('Nieprawidłowe aktualne hasło');
    } on UnauthorizedException catch (_) {
      if (!mounted) return;
      _showError('Sesja wygasła. Zaloguj się ponownie.');
    } on NetworkException catch (_) {
      if (!mounted) return;
      _showError('Brak połączenia z internetem.');
    } catch (e) {
      if (!mounted) return;
      _showError('Błąd zmiany hasła. Spróbuj ponownie.\n${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPasswordMatch() {
    if (_newPasswordValue.isEmpty || _confirmValue.isEmpty) {
      return const SizedBox.shrink();
    }
    final match = _newPasswordValue == _confirmValue;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(
            match ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 15,
            color: match ? const Color(0xFF16A34A) : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            match ? 'Hasła są zgodne' : 'Hasła nie są zgodne',
            style: TextStyle(
              fontSize: 13,
              color: match ? const Color(0xFF15803D) : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zmień hasło'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.purple,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Nowe hasło musi spełniać wszystkie wymagania bezpieczeństwa.',
                          style: TextStyle(
                            color: AppColors.purpleDark,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _oldCtrl,
                  obscureText: _obscureOld,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Aktualne hasło',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscureOld ? 'Pokaż hasło' : 'Ukryj hasło',
                      icon: Icon(
                        _obscureOld
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureOld = !_obscureOld),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Podaj aktualne hasło' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _newCtrl,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  onChanged: (v) => setState(() => _newPasswordValue = v),
                  decoration: InputDecoration(
                    labelText: 'Nowe hasło',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscureNew ? 'Pokaż hasło' : 'Ukryj hasło',
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    final err = PasswordValidator.validate(v);
                    if (err != null) return err;
                    if (v == _oldCtrl.text) {
                      return 'Nowe hasło musi różnić się od aktualnego';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                PasswordRequirements(password: _newPasswordValue),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onChanged: (v) => setState(() => _confirmValue = v),
                  onFieldSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: 'Potwierdź nowe hasło',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirm ? 'Pokaż hasło' : 'Ukryj hasło',
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Potwierdź nowe hasło';
                    if (v != _newCtrl.text) return 'Hasła nie są zgodne';
                    return null;
                  },
                ),
                _buildPasswordMatch(),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Zmień hasło',
                  onPressed: _saving ? null : _save,
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
