import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/kanban_column.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(projectId: widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskProvider>().loadTasks(
              projectId: widget.projectId,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/projects/${widget.projectId}/tasks/new'),
        backgroundColor: AppColors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: taskProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KanbanColumn(
                    status: TaskStatus.todo,
                    tasks: taskProvider.getByStatus(TaskStatus.todo),
                  ),
                  const SizedBox(width: 12),
                  KanbanColumn(
                    status: TaskStatus.inProgress,
                    tasks: taskProvider.getByStatus(TaskStatus.inProgress),
                  ),
                  const SizedBox(width: 12),
                  KanbanColumn(
                    status: TaskStatus.done,
                    tasks: taskProvider.getByStatus(TaskStatus.done),
                  ),
                ],
              ),
            ),
    );
  }
}
