import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/project_service.dart';
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
  ProjectModel? _project;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(projectId: widget.projectId);
      _loadProject();
    });
  }

  Future<void> _loadProject() async {
    try {
      final project = await ProjectService.getProject(widget.projectId);
      if (mounted) {
        final currentUserId = context.read<AuthProvider>().user?.id;
        debugPrint(
          '[PROJECT_DETAIL] projectId=${project.id} '
          'ownerId=${project.ownerId} currentUserId=$currentUserId '
          'isAdmin=${project.ownerId == currentUserId}',
        );
        setState(() => _project = project);
      }
    } catch (e) {
      debugPrint('[PROJECT_DETAIL] _loadProject error: $e');
    }
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    children: [
                      _buildFilterToggle(),
                      Expanded(
                        child: _KanbanView(
                          tasks: filteredTasks,
                          loading: taskProvider.loading,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildFilterToggle(),
                      Expanded(
                        child: _ListView(
                          tasks: filteredTasks,
                          loading: taskProvider.loading,
                        ),
                      ),
                    ],
                  ),
                  _StatsView(
                    tasks: allTasks,
                    loading: taskProvider.loading,
                    onRefresh: () => context.read<TaskProvider>().loadTasks(
                      projectId: widget.projectId,
                    ),
                  ),
                  _TeamView(project: _project, onRefresh: _loadProject),
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
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onSelected: (value) {
              if (value == 'delete') _confirmDeleteProject();
              if (value == 'leave') _confirmLeaveProject();
            },
            itemBuilder: (_) {
              final currentUserId = context.read<AuthProvider>().user?.id;
              final isAdmin = _project?.ownerId != null
                  ? _project!.ownerId == currentUserId
                  : false; // fallback: pokaż opuść jeśli nie znamy właściciela

              if (isAdmin) {
                return [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Usuń projekt',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              } else {
                return [
                  PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.exit_to_app_rounded,
                          color: AppColors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Opuść projekt',
                          style: GoogleFonts.poppins(
                            color: AppColors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }
            },
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          tabs: const [
            Tab(text: 'Kanban'),
            Tab(text: 'Lista'),
            Tab(text: 'Statystyki'),
            Tab(text: 'Zespół'),
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

  Future<void> _confirmDeleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Usuń projekt',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Czy na pewno chcesz usunąć projekt "${widget.projectName}"? Tej operacji nie można cofnąć.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Anuluj',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
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
      final ok = await context.read<ProjectProvider>().deleteProject(
        widget.projectId,
      );
      if (ok && mounted) {
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ProjectProvider>().error ?? 'Błąd usuwania projektu',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmLeaveProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Opuść projekt',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Czy na pewno chcesz opuścić projekt "${widget.projectName}"?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Anuluj',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Opuść',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<ProjectProvider>().leaveProject(
        widget.projectId,
      );
      if (ok && mounted) {
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ProjectProvider>().error ??
                  'Błąd opuszczania projektu',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index >= 2) return const SizedBox.shrink();
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
      },
    );
  }
}

// ─── Toggle Chip ─────────────────────────────────────────────────────────────

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

// ─── Kanban View ─────────────────────────────────────────────────────────────

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

// ─── List View ───────────────────────────────────────────────────────────────

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

// ─── Stats View ──────────────────────────────────────────────────────────────

class _StatsView extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool loading;
  final VoidCallback onRefresh;

  const _StatsView({
    required this.tasks,
    required this.loading,
    required this.onRefresh,
  });

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
              Icons.bar_chart_rounded,
              size: 64,
              color: AppColors.purple.withOpacity(0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'Brak zadań do analizy',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dodaj zadania, aby zobaczyć statystyki',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
    final inProgress = tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final total = tasks.length;

    final low = tasks.where((t) => t.priority == TaskPriority.low).length;
    final medium = tasks.where((t) => t.priority == TaskPriority.medium).length;
    final high = tasks.where((t) => t.priority == TaskPriority.high).length;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Postęp projektu',
              subtitle: 'Łącznie $total zadań',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatTile(
                  label: 'Do zrobienia',
                  count: todo,
                  total: total,
                  color: AppColors.orange,
                  icon: Icons.radio_button_unchecked_rounded,
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'W trakcie',
                  count: inProgress,
                  total: total,
                  color: AppColors.purple,
                  icon: Icons.timelapse_rounded,
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Gotowe',
                  count: done,
                  total: total,
                  color: AppColors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PieChartCard(
              sections: [
                _ChartSection(
                  label: 'Do zrobienia',
                  value: todo,
                  color: AppColors.orange,
                ),
                _ChartSection(
                  label: 'W trakcie',
                  value: inProgress,
                  color: AppColors.purple,
                ),
                _ChartSection(
                  label: 'Gotowe',
                  value: done,
                  color: AppColors.success,
                ),
              ],
              centerLabel: _percent(done, total),
              centerSub: 'ukończone',
            ),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Priorytety',
              subtitle: 'Rozkład wg ważności',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatTile(
                  label: 'Niski',
                  count: low,
                  total: total,
                  color: const Color(0xFF4CAF50),
                  icon: Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Średni',
                  count: medium,
                  total: total,
                  color: AppColors.orange,
                  icon: Icons.remove_rounded,
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Wysoki',
                  count: high,
                  total: total,
                  color: const Color(0xFFE53935),
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PieChartCard(
              sections: [
                _ChartSection(
                  label: 'Niski',
                  value: low,
                  color: const Color(0xFF4CAF50),
                ),
                _ChartSection(
                  label: 'Średni',
                  value: medium,
                  color: AppColors.orange,
                ),
                _ChartSection(
                  label: 'Wysoki',
                  value: high,
                  color: const Color(0xFFE53935),
                ),
              ],
              centerLabel: high > 0 ? '$high' : '0',
              centerSub: 'wysoki priorytet',
            ),
          ],
        ),
      ),
    );
  }

  String _percent(int count, int total) {
    if (total == 0) return '0%';
    return '${(count / total * 100).round()}%';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSection {
  final String label;
  final int value;
  final Color color;
  const _ChartSection({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _PieChartCard extends StatefulWidget {
  final List<_ChartSection> sections;
  final String centerLabel;
  final String centerSub;

  const _PieChartCard({
    required this.sections,
    required this.centerLabel,
    required this.centerSub,
  });

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.sections.fold<int>(0, (s, e) => s + e.value);
    final allZero = total == 0;

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
      padding: const EdgeInsets.all(20),
      child: allZero
          ? _emptyChart()
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touched = -1;
                                return;
                              }
                              _touched =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sections: List.generate(widget.sections.length, (i) {
                          final s = widget.sections[i];
                          final isTouched = i == _touched;
                          final radius = isTouched ? 56.0 : 48.0;
                          return PieChartSectionData(
                            value: s.value.toDouble(),
                            color: s.color,
                            radius: radius,
                            showTitle: false,
                          );
                        }),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 250),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.centerLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.centerSub,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.sections.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${s.label} (${s.value})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyChart() {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          'Brak danych do wyświetlenia',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Team View ────────────────────────────────────────────────────────────────

class _TeamView extends StatelessWidget {
  final ProjectModel? project;
  final Future<void> Function() onRefresh;

  const _TeamView({required this.project, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final members = project!.members;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: members.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 56,
                        color: AppColors.purple.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Brak członków projektu',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: members.length,
              itemBuilder: (_, i) => _MemberTile(member: members[i]),
            ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final initial = member.username.isNotEmpty
        ? member.username[0].toUpperCase()
        : '?';
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            gradient: AppColors.gradientPurple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          member.username,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          member.email,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
