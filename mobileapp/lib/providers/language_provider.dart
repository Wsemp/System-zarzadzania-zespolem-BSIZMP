import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_strings.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageProvider extends ChangeNotifier {
  static const _prefsKey = 'app_language_code';

  Locale _locale = const Locale('pl');

  Locale get locale => _locale;

  AppStrings get strings => AppStrings.of(_locale.languageCode);

  static const List<LanguageOption> languages = [
    LanguageOption(code: 'pl', name: 'Polski', flag: '🇵🇱'),
    LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'it', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'pt', name: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    LanguageOption(code: 'zh', name: '中文', flag: '🇨🇳'),
    LanguageOption(code: 'ja', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'ko', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    LanguageOption(code: 'hi', name: 'हिन्दी', flag: '🇮🇳'),
    LanguageOption(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    LanguageOption(code: 'nl', name: 'Nederlands', flag: '🇳🇱'),
  ];

  static List<Locale> get supportedLocales =>
      languages.map((l) => Locale(l.code)).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'pl';
    _locale = Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }

  LanguageOption get currentLanguage => languages.firstWhere(
    (l) => l.code == _locale.languageCode,
    orElse: () => languages.first,
  );
}
