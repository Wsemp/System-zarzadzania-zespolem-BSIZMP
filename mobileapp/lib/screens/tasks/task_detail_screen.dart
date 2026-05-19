import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final task = await TaskService.getTask(widget.taskId);
      setState(() {
        _task = task;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
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
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/tasks/${_task!.id}/edit', extra: _task),
            ),
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(task.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task.status.label,
              style: TextStyle(
                color: _statusColor(task.status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Opis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if (task.dueDate != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Termin: ${task.dueDate}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          if (task.assignedTo != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Przypisano do: ${task.assignedTo}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            'Zmień status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
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
                          ? _statusColor(s).withOpacity(0.1)
                          : null,
                      side: BorderSide(color: _statusColor(s)),
                    ),
                    child: Text(
                      s.label,
                      style: TextStyle(color: _statusColor(s), fontSize: 11),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(TaskStatus status) async {
    await context.read<TaskProvider>().updateStatus(_task!.id, status);
    setState(() => _task = _task!.copyWith(status: status));
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TaskProvider>().deleteTask(_task!.id);
      if (mounted) context.pop();
    }
  }
}
