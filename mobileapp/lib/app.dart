import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/task_model.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/invitations/invitations_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/projects_list_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/tasks/task_form_screen.dart';
import 'services/session_service.dart';

class TaskomatApp extends StatelessWidget {
  const TaskomatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Taskomat',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return _SessionWrapper(child: child ?? const SizedBox());
      },
    );
  }
}

class _SessionWrapper extends StatefulWidget {
  final Widget child;
  const _SessionWrapper({required this.child});

  @override
  State<_SessionWrapper> createState() => _SessionWrapperState();
}

class _SessionWrapperState extends State<_SessionWrapper> {
  AuthProvider? _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (_auth != auth) {
      _auth?.removeListener(_onAuthChanged);
      _auth = auth;
      _auth!.addListener(_onAuthChanged);
      _syncSession();
    }
  }

  void _onAuthChanged() => _syncSession();

  void _syncSession() {
    if (_auth?.isAuthenticated == true) {
      SessionService.start(_onTimeout);
    } else {
      SessionService.stop();
    }
  }

  void _onTimeout() async {
    await _auth?.logout();
    if (mounted) _router.go('/welcome');
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    SessionService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionService.reset(),
      child: widget.child,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) => OtpScreen(contact: state.extra as String?),
    ),
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
    GoRoute(
      path: '/change-password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/invitations',
      builder: (_, __) => const InvitationsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
  ],
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isAuth = auth.isAuthenticated;
    final loc = state.matchedLocation;
    const publicRoutes = ['/', '/welcome', '/login', '/register', '/otp'];
    if (!isAuth && !publicRoutes.contains(loc)) return '/welcome';
    return null;
  },
);
