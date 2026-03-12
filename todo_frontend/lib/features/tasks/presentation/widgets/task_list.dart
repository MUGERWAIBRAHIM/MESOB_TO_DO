import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/presentation/providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDate;
  
  const TaskList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${taskProvider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: taskProvider.fetchTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter tasks by selected date
    final tasksForDate = taskProvider.tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      final selectedDateOnly = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return taskDate.isAtSameMomentAs(selectedDateOnly);
    }).toList();

    if (tasksForDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rtl,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for today',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: tasksForDate.length,
      itemBuilder: (context, index) {
        final task = tasksForDate[index];
        return TaskItem(task: task);
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.go('/task/${task.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    taskProvider.toggleTaskCompletion(task.id);
                  },
                  activeColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.startTime} - ${task.endTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.completed 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: task.completed 
                              ? Colors.grey[400]
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
