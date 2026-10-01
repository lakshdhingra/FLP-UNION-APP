import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/manager/screens/manager_shell_screen.dart';
import '../../features/manager/screens/manager_dashboard_screen.dart';
import '../../features/manager/screens/manager_engineers_screen.dart';
import '../../features/manager/screens/manager_directory_screen.dart';
import '../../features/manager/screens/manager_help_screen.dart';
import '../../features/manager/screens/manager_profile_screen.dart';
import '../../features/manager/screens/engineer_detail_screen.dart';
import '../../features/manager/screens/engineer_form_screen.dart';
import '../../features/manager/screens/other_manager_profile_screen.dart';
import '../../features/admin/screens/admin_shell_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_managers_screen.dart';
import '../../features/admin/screens/admin_engineers_screen.dart';
import '../../features/admin/screens/admin_issues_screen.dart';
import '../../features/admin/screens/admin_states_screen.dart';
import '../../shared/models/user_role.dart';
import '../constants/app_colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (isLoading) return null;

      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute || state.matchedLocation == '/') {
        if (authState.user?.role == UserRole.ADMIN) {
          return '/admin/dashboard';
        }
        return '/manager/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Manager Shell Router
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ManagerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/dashboard',
                builder: (context, state) => const ManagerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/engineers',
                builder: (context, state) => const ManagerEngineersScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const EngineerFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return EngineerFormScreen(engineerId: id);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EngineerDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/managers',
                builder: (context, state) => const ManagerDirectoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return OtherManagerProfileScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/help',
                builder: (context, state) => const ManagerHelpScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/profile',
                builder: (context, state) => const ManagerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Shell Router
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/managers',
                builder: (context, state) => const AdminManagersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/engineers',
                builder: (context, state) => const AdminEngineersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/issues',
                builder: (context, state) => const AdminIssuesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/states',
                builder: (context, state) => const AdminStatesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
