import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
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

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOnlyMine = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final currentUserId = context.read<AuthProvider>().user?.id;

    final allTasks = taskProvider.tasks;
    final filteredTasks = _showOnlyMine && currentUserId != null
        ? allTasks.where((t) => t.assignedTo == currentUserId).toList()
        : allTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildTabBar(),
            _buildFilterToggle(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _KanbanView(
                    tasks: filteredTasks,
                    loading: taskProvider.loading,
                  ),
                  _ListView(
                    tasks: filteredTasks,
                    loading: taskProvider.loading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.projectName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => context.read<TaskProvider>().loadTasks(
              projectId: widget.projectId,
            ),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: AppColors.gradientPurple,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(text: 'Kanban'),
            Tab(text: 'Lista'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _ToggleChip(
              label: 'Moje zadania',
              selected: _showOnlyMine,
              onTap: () => setState(() => _showOnlyMine = true),
            ),
            _ToggleChip(
              label: 'Wszystkie',
              selected: !_showOnlyMine,
              onTap: () => setState(() => _showOnlyMine = false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientPurple,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () =>
            context.push('/projects/${widget.projectId}/tasks/new'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.gradientPurple : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _KanbanView extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool loading;
  const _KanbanView({required this.tasks, required this.loading});

  List<TaskModel> _byStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).toList();

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanbanColumn(
            status: TaskStatus.todo,
            tasks: _byStatus(TaskStatus.todo),
          ),
          const SizedBox(width: 12),
          KanbanColumn(
            status: TaskStatus.inProgress,
            tasks: _byStatus(TaskStatus.inProgress),
          ),
          const SizedBox(width: 12),
          KanbanColumn(
            status: TaskStatus.done,
            tasks: _byStatus(TaskStatus.done),
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool loading;
  const _ListView({required this.tasks, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 56,
              color: AppColors.purple.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Brak zadań w tym projekcie',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskListTile(task: tasks[i]),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  final TaskModel task;
  const _TaskListTile({required this.task});

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.orange;
      case TaskStatus.inProgress:
        return AppColors.purple;
      case TaskStatus.done:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        leading: Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            color: _statusColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: task.dueDate != null
            ? Text(
                task.dueDate!.length > 10
                    ? task.dueDate!.substring(0, 10)
                    : task.dueDate!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        onTap: () => context.push('/tasks/${task.id}'),
      ),
    );
  }
}
