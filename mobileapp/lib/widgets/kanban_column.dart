import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<TaskModel> tasks;

  const KanbanColumn({super.key, required this.status, required this.tasks});

  Color get _color {
    switch (status) {
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
    return SizedBox(
      width: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Nagłówek kolumny (stały) ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status.label,
                  style: GoogleFonts.poppins(
                    color: _color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: GoogleFonts.poppins(
                      color: _color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // ─── Lista zadań (scrollowalna pionowo) ─────────────────────────
          Expanded(
            child: tasks.isEmpty
                ? Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Center(
                      child: Text(
                        'Brak zadań',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    children: tasks.map((task) => TaskCard(task: task)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
