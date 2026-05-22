import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/auth/token_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/gradient_button.dart';

const _kNotifMentions = 'notif_mentions';
const _kNotifNewTasks = 'notif_new_tasks';
const _kNotifStatusChanges = 'notif_status_changes';

// ══════════════════════════════════════════════════════════════════════════════
// GŁÓWNY EKRAN PROFILU
// ══════════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final id = await TokenStorage.getUserId();
      if (id != null) {
        final user = await UserService.getUser(id);
        if (mounted) setState(() => _user = user);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _showLanguagePicker() {
    final langProv = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LanguagePickerSheet(
        current: langProv.currentLanguage.code,
        onSelected: (code) {
          langProv.setLocale(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().strings;
    final langProv = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader().animate().fadeIn(duration: 400.ms),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.purple,
                          label: s.profileData,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileDataScreen(user: _user),
                              ),
                            );
                            _load();
                          },
                        ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          iconColor: AppColors.orange,
                          label: s.notifications,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          ),
                        ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.language_rounded,
                          iconColor: AppColors.purple,
                          label: s.language,
                          subtitle:
                              '${langProv.currentLanguage.flag}  ${langProv.currentLanguage.name}',
                          onTap: _showLanguagePicker,
                        ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: AppColors.purple,
                          label: s.changePassword,
                          onTap: () => context.push('/change-password'),
                        ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.logout_rounded,
                          iconColor: AppColors.error,
                          label: s.logout,
                          labelColor: AppColors.error,
                          showChevron: false,
                          onTap: () async {
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) context.go('/welcome');
                          },
                        ).animate().fadeIn(delay: 340.ms, duration: 350.ms),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final username = _user?.username ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final s = context.read<LanguageProvider>().strings;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPurple),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              username,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_user?.email.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                _user!.email,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
            if (_user?.isStaff == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  s.administrator,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PODSTRONA: Dane profilu
// ══════════════════════════════════════════════════════════════════════════════

class ProfileDataScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileDataScreen({super.key, required this.user});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user?.username ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.user == null) return;
    setState(() => _saving = true);
    try {
      await UserService.updateUser(
        widget.user!.id,
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (mounted) {
        final s = context.read<LanguageProvider>().strings;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.profileUpdated, style: GoogleFonts.poppins()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          s.profileData,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameCtrl,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                labelText: s.username,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                labelText: s.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: s.saveChanges,
              onPressed: _saving ? null : _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PODSTRONA: Ustawienia powiadomień
// ══════════════════════════════════════════════════════════════════════════════

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notifMentions = true;
  bool _notifNewTasks = true;
  bool _notifStatusChanges = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifMentions = prefs.getBool(_kNotifMentions) ?? true;
        _notifNewTasks = prefs.getBool(_kNotifNewTasks) ?? true;
        _notifStatusChanges = prefs.getBool(_kNotifStatusChanges) ?? false;
        _loaded = true;
      });
    }
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          s.notifications,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loaded
          ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _NotifToggle(
                  icon: Icons.alternate_email_rounded,
                  iconColor: AppColors.purple,
                  label: s.notifMentions,
                  description: s.notifMentionsDesc,
                  value: _notifMentions,
                  onChanged: (v) {
                    setState(() => _notifMentions = v);
                    _save(_kNotifMentions, v);
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _NotifToggle(
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.orange,
                  label: s.notifNewTasks,
                  description: s.notifNewTasksDesc,
                  value: _notifNewTasks,
                  onChanged: (v) {
                    setState(() => _notifNewTasks = v);
                    _save(_kNotifNewTasks, v);
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _NotifToggle(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: AppColors.success,
                  label: s.notifStatusChanges,
                  description: s.notifStatusChangesDesc,
                  value: _notifStatusChanges,
                  onChanged: (v) {
                    setState(() => _notifStatusChanges = v);
                    _save(_kNotifStatusChanges, v);
                  },
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bottom sheet wyboru języka
// ══════════════════════════════════════════════════════════════════════════════

class _LanguagePickerSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;

  const _LanguagePickerSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final s = context.read<LanguageProvider>().strings;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      // Ogranicz wysokość do 80% ekranu, żeby lista mogła się scrollować
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle + tytuł — stałe, nie scrollowane
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                Text(
                  s.selectLanguage,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Scrollowalna lista języków
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              shrinkWrap: true,
              children: LanguageProvider.languages.map((lang) {
                final isSelected = lang.code == current;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.purple
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.purple,
                          size: 20,
                        )
                      : null,
                  onTap: () => onSelected(lang.code),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reużywalne widgety
// ══════════════════════════════════════════════════════════════════════════════

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? subtitle;
  final bool showChevron;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.subtitle,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: labelColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purple,
          ),
        ],
      ),
    );
  }
}
