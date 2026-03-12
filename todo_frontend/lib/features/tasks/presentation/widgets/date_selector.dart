import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/presentation/providers/task_provider.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedDate = taskProvider.selectedDate ?? DateTime.now();
    
    // Generate dates for the next 7 days
    final dates = List.generate(7, (index) {
      return DateTime.now().add(Duration(days: index));
    });

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          
          return GestureDetector(
            onTap: () {
              taskProvider.setSelectedDate(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayAbbreviation(date.weekday),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

