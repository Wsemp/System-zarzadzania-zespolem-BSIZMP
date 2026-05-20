class PasswordValidator {
  static const int minLength = 8;

  static bool hasMinLength(String p) => p.length >= minLength;
  static bool hasUppercase(String p) => p.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String p) => p.contains(RegExp(r'[a-z]'));
  static bool hasDigit(String p) => p.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String p) => p.contains(RegExp(r'[^a-zA-Z0-9]'));

  static bool isValid(String p) =>
      hasMinLength(p) &&
      hasUppercase(p) &&
      hasLowercase(p) &&
      hasDigit(p) &&
      hasSpecialChar(p);

  static String? validate(String? value) {
    if (value == null || value.isEmpty) return 'Hasło jest wymagane';
    if (!hasMinLength(value)) return 'Minimum $_minLength znaków';
    if (!hasUppercase(value)) return 'Wymagana co najmniej 1 wielka litera';
    if (!hasLowercase(value)) return 'Wymagana co najmniej 1 mała litera';
    if (!hasDigit(value)) return 'Wymagana co najmniej 1 cyfra';
    if (!hasSpecialChar(value)) return 'Wymagany co najmniej 1 znak specjalny';
    return null;
  }

  static const int _minLength = minLength;
}
