import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Powiadomienia'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text(
                'Oznacz wszystkie',
                style: TextStyle(color: AppColors.purple),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
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
        const Text(
          'Brak powiadomień',
          style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotifCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Card(
      color: n.isRead ? Colors.white : AppColors.purple.withOpacity(0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!n.isRead) {
            context.read<NotificationProvider>().markAsRead(n.id);
          }
          if (n.taskId != null) {
            context.push('/tasks/${n.taskId}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: n.isRead
                      ? AppColors.divider
                      : AppColors.purple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  n.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: n.isRead ? AppColors.textSecondary : AppColors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.message,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (n.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(n.createdAt),
                        style: const TextStyle(
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
                  margin: const EdgeInsets.only(top: 4),
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
      if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
      if (diff.inHours < 24) return '${diff.inHours} godz. temu';
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
