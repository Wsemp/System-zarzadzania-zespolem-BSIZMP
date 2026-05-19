import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/task_model.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/projects_list_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/tasks/task_form_screen.dart';

class TaskomatApp extends StatelessWidget {
  const TaskomatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Taskomat',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/projects', builder: (_, __) => const ProjectsListScreen()),
    GoRoute(
      path: '/projects/:id',
      builder: (_, state) => ProjectDetailScreen(
        projectId: int.parse(state.pathParameters['id']!),
        projectName: state.extra as String? ?? 'Projekt',
      ),
    ),
    GoRoute(
      path: '/projects/:id/tasks/new',
      builder: (_, state) =>
          TaskFormScreen(projectId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/tasks/:id',
      builder: (_, state) =>
          TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      builder: (_, state) => TaskFormScreen(task: state.extra as TaskModel?),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isAuth = auth.isAuthenticated;
    final loc = state.matchedLocation;
    final publicRoutes = ['/', '/login', '/register'];
    if (!isAuth && !publicRoutes.contains(loc)) return '/login';
    return null;
  },
);
