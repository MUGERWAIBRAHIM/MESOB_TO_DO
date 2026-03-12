import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:todo_app/features/tasks/presentation/widgets/date_selector.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.setSelectedDate(DateTime.now());
      taskProvider.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedDate = taskProvider.selectedDate ?? DateTime.now();

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedDate.day} ${_getMonthName(selectedDate.month)}',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '${selectedDate.year}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),

            // Settings icon
            InkWell(
              onTap: () => context.go('/settings'),
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                child: Icon(
                  Icons.settings,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),

      body: taskProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    taskProvider.error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => taskProvider.fetchTasks(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Today Header + Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tasksForDate.length} tasks',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/add-task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add New'),
                      ),
                    ],
                  ),
                ),

                // Date Selector
                const DateSelector(),

                // Task Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Tasks',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${tasksForDate.length} tasks',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Task List
                Expanded(
                  child: TaskList(selectedDate: selectedDate),
                ),
              ],
            ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
