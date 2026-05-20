import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Powiadomienia',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                'Oznacz wszystkie',
                style: GoogleFonts.poppins(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            onPressed: () => provider.load(),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: () => provider.load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: provider.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _NotifCard(notification: provider.notifications[i]),
              ),
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 64,
          color: AppColors.purple.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Brak powiadomień',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotifCard({required this.notification});

  IconData get _icon {
    final t = (notification.type ?? '').toLowerCase();
    final lower = notification.message.toLowerCase();

    if (t.contains('invitation') || t.contains('invited') ||
        lower.contains('invitation') || lower.contains('invited')) {
      return Icons.mail_outline_rounded;
    }
    if (t.contains('project') || lower.contains('project')) {
      return Icons.folder_rounded;
    }
    if (t.contains('task') || t.contains('assigned') || t.contains('status') ||
        lower.contains('task') || lower.contains('assigned')) {
      return Icons.task_alt_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color get _iconColor {
    final t = (notification.type ?? '').toLowerCase();
    final lower = notification.message.toLowerCase();

    if (t.contains('invitation') || lower.contains('invitation')) {
      return AppColors.orange;
    }
    if (t.contains('closed') || lower.contains('closed')) {
      return AppColors.textSecondary;
    }
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Container(
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : AppColors.purple.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: n.isRead
            ? null
            : Border.all(color: AppColors.purple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () {
          if (!n.isRead) {
            context.read<NotificationProvider>().markAsRead(n.id);
          }
          if (n.taskId != null) {
            context.push('/tasks/${n.taskId}');
          } else if (n.projectId != null) {
            context.push('/projects/${n.projectId}', extra: n.projectName ?? 'Projekt');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(n.isRead ? 0.06 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.displayMessage,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight:
                            n.isRead ? FontWeight.w400 : FontWeight.w600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (n.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(n.createdAt),
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'przed chwilą';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
      if (diff.inHours < 24) return '${diff.inHours} godz. temu';
      if (diff.inDays == 1) return 'wczoraj';
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
