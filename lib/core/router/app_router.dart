import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_editor/features/home/presentation/pages/home_page.dart';
import 'package:photo_editor/features/auth/presentation/pages/login_screen.dart';
import 'package:photo_editor/features/auth/presentation/pages/register_screen.dart';
import 'package:photo_editor/features/payment/presentation/pages/subscription_screen.dart';
import 'package:photo_editor/features/onboarding/presentation/pages/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        '/onboarding', // Temporary initial location, should verify shared_preferences using a redirection guard or loading screen
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
}
