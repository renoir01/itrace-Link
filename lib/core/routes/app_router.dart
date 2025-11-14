import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/language_selection_screen.dart';
import '../../features/auth/screens/user_type_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        name: 'language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/user-type-selection',
        name: 'user-type-selection',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) {
          final userType = state.extra as String?;
          return RegistrationScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String;
          return OtpVerificationScreen(phoneNumber: phoneNumber);
        },
      ),

      // Main Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Farmer Routes
      GoRoute(
        path: '/farmer/register-planting',
        name: 'farmer-register-planting',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/farmer/harvest-management',
        name: 'farmer-harvest-management',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/farmer/orders',
        name: 'farmer-orders',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),

      // Aggregator Routes
      GoRoute(
        path: '/aggregator/find-farmers',
        name: 'aggregator-find-farmers',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/aggregator/place-order',
        name: 'aggregator-place-order',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/aggregator/my-orders',
        name: 'aggregator-my-orders',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),

      // Institution Routes
      GoRoute(
        path: '/institution/post-requirement',
        name: 'institution-post-requirement',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/institution/view-bids',
        name: 'institution-view-bids',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/institution/verify-traceability',
        name: 'institution-verify-traceability',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),

      // Agro-Dealer Routes
      GoRoute(
        path: '/agro-dealer/inventory',
        name: 'agro-dealer-inventory',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/agro-dealer/record-sale',
        name: 'agro-dealer-record-sale',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),

      // Seed Producer Routes
      GoRoute(
        path: '/seed-producer/dealers',
        name: 'seed-producer-dealers',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/seed-producer/reports',
        name: 'seed-producer-reports',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),

      // Common Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const Placeholder(), // TODO: Create screen
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'order-details',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return const Placeholder(); // TODO: Create screen
        },
      ),
      GoRoute(
        path: '/traceability/:batchId',
        name: 'traceability-details',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId']!;
          return const Placeholder(); // TODO: Create screen
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
