import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void didUpdateWidget(covariant TaskDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new taskId comes in, reload task
    if (oldWidget.taskId != widget.taskId) {
      _loadTask();
    }
  }

  void _loadTask() {
    setState(() => _isLoading = true);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => Task(
        id: widget.taskId,
        title: 'Task not found',
        description: '',
        dueDate: DateTime.now(),
        startTime: '',
        endTime: '',
        category: '',
        completed: false,
      ),
    );

    setState(() {
      _task = task;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _task == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Task Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryPurple),
            onPressed: () {
              // Pass the current task to TaskFormScreen
              context.push('/add-task', extra: _task);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _task!.completed,
                  activeColor: AppTheme.primaryPurple,
                  onChanged: (value) async {
                    setState(() {
                      _task = _task!.copyWith(completed: value ?? false);
                    });
                    await Provider.of<TaskProvider>(context, listen: false)
                        .toggleTaskCompletion(_task!.id!);
                  },
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _task!.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: _task!.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),

            // Task Details
            _buildDetailRow(Icons.calendar_today,
                DateFormat('dd MMM yyyy').format(_task!.dueDate)),
            const SizedBox(height: 16.0),
            _buildDetailRow(
                Icons.access_time, '${_task!.startTime} - ${_task!.endTime}'),
            const SizedBox(height: 16.0),
            _buildDetailRow(Icons.category, _task!.category),
            const SizedBox(height: 32.0),

            // Description Section
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              _task!.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<TaskProvider>(context, listen: false)
          .deleteTask(_task!.id!);
      if (mounted) context.go('/home');
    }
  }
}
