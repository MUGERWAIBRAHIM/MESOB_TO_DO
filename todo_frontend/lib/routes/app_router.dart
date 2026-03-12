import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:todo_app/features/auth/presentation/screens/register_screen.dart';
import 'package:todo_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:todo_app/features/tasks/presentation/screens/home_screen.dart';
import 'package:todo_app/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:todo_app/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:todo_app/features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Task Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/home', // <-- add this
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/edit-task/:id',
        builder: (context, state) {
        final taskId = state.pathParameters['id']!;
    // You need to get the task from your state management
    // For now, we'll pass null and handle it in the TaskFormScreen
        return TaskFormScreen(task: null);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}