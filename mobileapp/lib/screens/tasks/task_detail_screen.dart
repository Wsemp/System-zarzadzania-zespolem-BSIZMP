import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String _fmtDate(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw.length > 10 ? raw.substring(0, 10) : raw;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
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

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50);
      case TaskPriority.medium:
        return AppColors.orange;
      case TaskPriority.high:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Szczegóły zadania',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.textSecondary,
              tooltip: 'Edytuj',
              onPressed: () async {
                await context.push('/tasks/${_task!.id}/edit', extra: _task);
                _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              tooltip: 'Usuń',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
          ? Center(
              child: Text(
                'Nie znaleziono zadania',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final task = _task!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(
                  status: task.status,
                  color: _statusColor(task.status),
                ),
                const SizedBox(width: 8),
                _PriorityBadge(
                  priority: task.priority,
                  color: _priorityColor(task.priority),
                ),
                if (task.area != null) ...[
                  const SizedBox(width: 8),
                  _AreaBadge(area: task.area!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionLabel('Opis'),
              const SizedBox(height: 6),
              Text(
                task.description,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _infoCard(task),
            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 16),
            _sectionLabel('Zmień status'),
            const SizedBox(height: 12),
            _statusButtons(task),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(TaskModel task) {
    final rows = <Widget>[];

    if (task.dueDate != null) {
      rows.add(
        _InfoRow(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.orange,
          label: 'Termin',
          value: _fmtDate(task.dueDate!),
        ),
      );
    }

    if (_assignee != null || task.assignedTo != null) {
      rows.add(
        _InfoRow(
          icon: Icons.person_rounded,
          iconColor: AppColors.purple,
          label: 'Osoba przypisana',
          value: _assignee?.username ?? '#${task.assignedTo}',
          avatar: (_assignee?.username ?? '#${task.assignedTo}')[0]
              .toUpperCase(),
        ),
      );
    }

    if (task.anonymousReporter) {
      rows.add(
        const _InfoRow(
          icon: Icons.visibility_off_rounded,
          iconColor: AppColors.textSecondary,
          label: 'Zgłaszający',
          value: 'Anonimowo',
        ),
      );
    } else if (task.reportedByUsername != null &&
        task.reportedByUsername!.isNotEmpty) {
      rows.add(
        _InfoRow(
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.textSecondary,
          label: 'Zgłaszający',
          value: task.reportedByUsername!,
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows
            .expand((w) => [w, const SizedBox(height: 12)])
            .take(rows.length * 2 - 1)
            .toList(),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.divider);

  Text _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: AppColors.purple,
      letterSpacing: 0.3,
    ),
  );

  Widget _statusButtons(TaskModel task) {
    return Row(
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                s.label,
                style: GoogleFonts.poppins(
                  color: selected ? _statusColor(s) : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

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
        title: Text(
          'Usuń zadanie',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Czy na pewno chcesz usunąć to zadanie?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Usuń',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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

// ─── Badges ──────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final Color color;
  const _PriorityBadge({required this.priority, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            priority.label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaBadge extends StatelessWidget {
  final TaskArea area;
  const _AreaBadge({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        area.label,
        style: GoogleFonts.poppins(
          color: AppColors.purple,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────────────────────

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
                  style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
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
