import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/months/presentation/pages/months_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/expense',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Expense) {
            return AddExpensePage(expense: extra);
          }

          if (extra is Map<String, dynamic>) {
            return AddExpensePage(
              expense: extra['expense'] as Expense?,
              initialCategoryId: extra['categoryId'] as String?,
            );
          }

          return const AddExpensePage();
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/months',
                builder: (context, state) => const MonthsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    const labels = ['الرئيسية', 'الإحصائيات', 'الأشهر', 'الحساب'];
    const icons = [
      Icons.home_rounded,
      Icons.bar_chart_rounded,
      Icons.calendar_month_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: List.generate(
          labels.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
    );
  }
}
