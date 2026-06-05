import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:loops_flutter/app/shell/main_screen.dart';
import 'package:loops_flutter/features/activity/presentation/screens/activity_screen.dart';
import 'package:loops_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:loops_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:loops_flutter/features/explore/presentation/screens/explore_screen.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_screen.dart';
import 'package:loops_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';

/// The app's [GoRouter], exposed as a provider so it can read other providers
/// (e.g. the auth repository) for its redirect guard.
///
/// Route map:
///   ShellRoute (wraps the four primary tabs in [MainScreen])
///     /          → Feed (Home)
///     /explore   → Explore
///     /activity  → Activity
///     /profile   → Profile (own)
///   /login       → Login (outside the shell — no nav chrome)
///   /user/:id    → Another user's profile (pushed full-screen)
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // Auth guard: bounce signed-out users to /login and signed-in users away
    // from it. Returning null means "no redirect — proceed as requested".
    redirect: (context, state) async {
      final authRepo = ref.read(authRepositoryProvider);
      final isAuthenticated = await authRepo.isAuthenticated();
      final isLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginPage) return '/login';
      if (isAuthenticated && isLoginPage) return '/';
      return null;
    },
    routes: [
      // Primary tabs share the persistent shell (nav bars stay mounted).
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const FeedScreen()),
          GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen()),
          GoRoute(
              path: '/activity', builder: (_, _) => const ActivityScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),

      // Full-screen routes rendered outside the shell.
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/user/:id',
        builder: (_, state) =>
            UserProfileScreen(userId: state.pathParameters['id']!),
      ),
    ],
  );
});
