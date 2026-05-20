import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/task_provider.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;
  UserModel? _assignee;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final task = await TaskService.getTask(widget.taskId);
      UserModel? assignee;
      if (task.assignedTo != null) {
        try {
          assignee = await UserService.getUser(task.assignedTo!);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _task = task;
          _assignee = assignee;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return AppColors.textSecondary;
      case TaskStatus.inProgress:
        return AppColors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zadania'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edytuj',
              onPressed: () async {
                await context.push('/tasks/${_task!.id}/edit', extra: _task);
                _load(); // odśwież po edycji
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Usuń',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
          ? const Center(child: Text('Nie znaleziono zadania'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final task = _task!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge statusu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(task.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.status.label,
                style: TextStyle(
                  color: _statusColor(task.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tytuł
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // Opis
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionLabel('Opis'),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            // Termin
            if (task.dueDate != null) ...[
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.orange,
                label: 'Termin',
                value: task.dueDate!,
              ),
            ],

            // Przypisane do
            if (_assignee != null || task.assignedTo != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.person_rounded,
                iconColor: AppColors.purple,
                label: 'Przypisano do',
                value: _assignee?.username ?? '#${task.assignedTo}',
                avatar: _assignee?.username[0].toUpperCase(),
              ),
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Zmień status
            _sectionLabel('Zmień status'),
            const SizedBox(height: 12),
            Row(
              children: TaskStatus.values.map((s) {
                final selected = task.status == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: selected ? null : () => _changeStatus(s),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected
                            ? _statusColor(s).withOpacity(0.12)
                            : null,
                        side: BorderSide(
                          color: selected ? _statusColor(s) : AppColors.divider,
                          width: selected ? 1.5 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        s.label,
                        style: TextStyle(
                          color: selected
                              ? _statusColor(s)
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: AppColors.purple,
      letterSpacing: 0.3,
    ),
  );

  Future<void> _changeStatus(TaskStatus status) async {
    final ok = await context.read<TaskProvider>().updateStatus(
      _task!.id,
      status,
    );
    if (ok && mounted) {
      setState(() => _task = _task!.copyWith(status: status));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<TaskProvider>().error ?? 'Błąd zmiany statusu',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Usuń zadanie'),
        content: const Text('Czy na pewno chcesz usunąć to zadanie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<TaskProvider>().deleteTask(_task!.id);
      if (ok && mounted) context.pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? avatar;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatar != null
            ? CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.purple.withOpacity(0.12),
                child: Text(
                  avatar!,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
