import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (task.assignedTo != null)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0x337C3AED),
                      child: Text(
                        task.assignedTo!.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
