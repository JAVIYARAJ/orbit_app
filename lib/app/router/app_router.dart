import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/router/app_shell.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/authentication/presentation/pages/login_page.dart';
import 'package:orbit_app/features/authentication/presentation/pages/splash_page.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:orbit_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:orbit_app/features/notes/presentation/pages/note_detail_page.dart';
import 'package:orbit_app/features/notes/presentation/pages/notes_page.dart';
import 'package:orbit_app/features/notes/presentation/pages/folder_notes_page.dart';
import 'package:orbit_app/features/projects/presentation/pages/project_detail_page.dart';
import 'package:orbit_app/features/projects/presentation/pages/projects_page.dart';
import 'package:orbit_app/features/projects/presentation/pages/create_project_page.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';
import 'package:orbit_app/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:orbit_app/features/tasks/presentation/pages/tasks_page.dart';
import 'package:orbit_app/features/tasks/presentation/pages/create_task_page.dart';
import 'package:orbit_app/features/tasks/presentation/bloc/create_task_bloc.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/utilities/presentation/pages/utilities_page.dart';
import 'package:orbit_app/features/secrets/presentation/pages/secrets_page.dart';
import 'package:orbit_app/features/profile/presentation/pages/profile_page.dart';
import 'package:orbit_app/features/github/presentation/pages/github_page.dart';
import 'package:orbit_app/features/vercel/presentation/pages/vercel_page.dart';
import 'package:orbit_app/features/learning/presentation/pages/learning_path_page.dart';
import 'package:orbit_app/features/learning/presentation/pages/learning_detail_page.dart';
import 'package:orbit_app/features/time_tracking/presentation/pages/time_tracking_page.dart';
import 'package:orbit_app/features/workspaces/presentation/pages/workspace_selection_page.dart';
import 'package:orbit_app/features/notifications/presentation/pages/notifications_page.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String selectWorkspace = '/select-workspace';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectAdd = '/projects/add';
  static const String projectDetail = '/projects/detail';
  static const String tasks = '/tasks';
  static const String taskAdd = '/tasks/add';
  static const String taskDetail = '/tasks/detail';
  static const String notes = '/notes';
  static const String noteDetail = '/notes/detail';
  static const String utilities = '/utilities';
  static const String secrets = '/profile/secrets'; // Moved under profile
  static const String github = '/profile/github';
  static const String vercel = '/profile/vercel';
  static const String learning = '/profile/learning';
  static const String learningDetail = '/profile/learning/detail';
  static const String timeTracking = '/profile/time-tracking';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

/// Builds the app router bound to [authCubit].
///
/// A redirect guard keeps unauthenticated users out of the app shell and sends
/// authenticated users straight to the dashboard. [refreshListenable] re-runs
/// the guard whenever the session changes (password login, Google OAuth return,
/// or sign-out).
GoRouter buildAppRouter(AuthCubit authCubit) => GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  refreshListenable: _GoRouterRefreshStream(authCubit.stream),
  redirect: (context, state) {
    final status = authCubit.state.status;
    final location = state.matchedLocation;
    final isLogin = location == AppRoutes.login;
    final isSplash = location == AppRoutes.splash;

    // The splash screen drives its own exit once the session resolves.
    if (isSplash) return null;

    if (status == AuthStatus.authenticated) {
      // Signed in: keep them out of the login page.
      return isLogin ? AppRoutes.selectWorkspace : null;
    }

    if (status == AuthStatus.unauthenticated) {
      // Signed out: only the login page is reachable.
      return isLogin ? null : AppRoutes.login;
    }

    // Session still unknown — hold on the splash screen.
    return AppRoutes.splash;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.selectWorkspace,
      name: 'selectWorkspace',
      builder: (context, state) => const WorkspaceSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),

    // Persistent bottom-nav shell — the nav bar stays mounted while only the
    // active branch's body swaps, so tab switches don't reload the whole page.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<DashboardCubit>(),
                child: const DashboardPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.projects,
              name: 'projects',
              builder: (context, state) => const ProjectsPage(),
              routes: [
                // Pushed within the Projects branch so the shell's bottom nav
                // stays visible and `context.pop()` returns to the list.
                GoRoute(
                  path: 'detail/:id',
                  name: 'projectDetail',
                  builder: (context, state) => ProjectDetailPage(
                    projectId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'add',
                  name: 'projectAdd',
                  builder: (context, state) => const CreateProjectPage(),
                ),
                GoRoute(
                  path: 'edit',
                  name: 'projectEdit',
                  builder: (context, state) => CreateProjectPage(
                    project: state.extra as ProjectEntity,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tasks,
              name: 'tasks',
              builder: (context, state) => const TasksPage(),
              routes: [
                GoRoute(
                  path: 'detail/:taskId',
                  name: 'taskDetail',
                  builder: (context, state) => TaskDetailPage(
                    taskId: state.pathParameters['taskId']!,
                  ),
                ),
                GoRoute(
                  path: 'add',
                  name: 'taskAdd',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<CreateTaskBloc>(),
                    child: CreateTaskPage(
                      tasks: state.extra as List<TaskEntity>? ?? [],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.notes,
              name: 'notes',
              builder: (context, state) => const NotesPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  name: 'noteDetail',
                  builder: (context, state) => const NoteDetailPage(),
                ),
                GoRoute(
                  path: 'folder/:folderId',
                  name: 'folderNotes',
                  builder: (context, state) {
                    final folderId = state.pathParameters['folderId']!;
                    final folderName = state.uri.queryParameters['name'] ?? 'Notes';
                    return FolderNotesPage(folderId: folderId, folderName: folderName);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'secrets',
                  name: 'secrets',
                  builder: (context, state) => const SecretsPage(),
                ),
                // Utilities can be added as a route here or we can keep it standalone
                GoRoute(
                  path: 'utilities',
                  name: 'utilities',
                  builder: (context, state) => const UtilitiesPage(),
                ),
                GoRoute(
                  path: 'time-tracking',
                  name: 'timeTracking',
                  builder: (context, state) => const TimeTrackingPage(),
                ),
                GoRoute(
                  path: 'github',
                  name: 'github',
                  builder: (context, state) => const GithubPage(),
                ),
                GoRoute(
                  path: 'vercel',
                  name: 'vercel',
                  builder: (context, state) => const VercelPage(),
                ),
                GoRoute(
                  path: 'learning',
                  name: 'learning',
                  builder: (context, state) => const LearningPathPage(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'learningDetail',
                      builder: (context, state) => const LearningDetailPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Adapts a [Stream] (the auth cubit's state stream) into a [Listenable] so
/// `GoRouter.refreshListenable` re-evaluates the redirect on every emission.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
