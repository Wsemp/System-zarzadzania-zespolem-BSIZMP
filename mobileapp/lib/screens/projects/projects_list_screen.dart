import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/project_provider.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
      context.read<NotificationProvider>().load();
      context.read<InvitationProvider>().load();
    });
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nowy projekt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nazwa projektu'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await context.read<ProjectProvider>().createProject(
                nameCtrl.text.trim(),
                descCtrl.text.trim(),
              );
            },
            child: const Text('Utwórz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>();
    final notifications = context.watch<NotificationProvider>();
    final invitations = context.watch<InvitationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Projekty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Zaproszenia
          _BadgeIcon(
            icon: Icons.mail_outline_rounded,
            count: invitations.pendingCount,
            onTap: () => context.push('/invitations'),
          ),
          // Powiadomienia
          _BadgeIcon(
            icon: Icons.notifications_outlined,
            count: notifications.unreadCount,
            onTap: () => context.push('/notifications'),
          ),
          // Profil
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nowy projekt',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: projects.loading
          ? const Center(child: CircularProgressIndicator())
          : projects.projects.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: () async {
                await projects.loadProjects();
                await notifications.load();
                await invitations.load();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.projects.length,
                itemBuilder: (_, i) =>
                    _ProjectCard(project: projects.projects[i]),
              ),
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_open,
          size: 64,
          color: AppColors.purple.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'Brak projektów',
          style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Utwórz swój pierwszy projekt',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(icon: Icon(icon), onPressed: onTap),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            context.push('/projects/${project.id}', extra: project.name),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
