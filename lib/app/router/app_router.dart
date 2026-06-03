import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/router/app_shell.dart';
import 'package:orbit_app/features/authentication/presentation/pages/login_page.dart';
import 'package:orbit_app/features/authentication/presentation/pages/splash_page.dart';
import 'package:orbit_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:orbit_app/features/notes/presentation/pages/note_detail_page.dart';
import 'package:orbit_app/features/notes/presentation/pages/notes_page.dart';
import 'package:orbit_app/features/projects/presentation/pages/project_detail_page.dart';
import 'package:orbit_app/features/projects/presentation/pages/projects_page.dart';
import 'package:orbit_app/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:orbit_app/features/tasks/presentation/pages/tasks_page.dart';
import 'package:orbit_app/features/utilities/presentation/pages/utilities_page.dart';
import 'package:orbit_app/features/secrets/presentation/pages/secrets_page.dart';
import 'package:orbit_app/features/profile/presentation/pages/profile_page.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/detail';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/detail';
  static const String notes = '/notes';
  static const String noteDetail = '/notes/detail';
  static const String utilities = '/utilities';
  static const String secrets = '/profile/secrets'; // Moved under profile
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
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
              builder: (context, state) => const DashboardPage(),
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
                  path: 'detail',
                  name: 'projectDetail',
                  builder: (context, state) => const ProjectDetailPage(),
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
                  path: 'detail',
                  name: 'taskDetail',
                  builder: (context, state) => const TaskDetailPage(),
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
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
