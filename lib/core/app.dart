import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/categories/presentation/cubit/categories_cubit.dart';
import '../features/expenses/presentation/cubit/expenses_cubit.dart';
import '../features/months/presentation/cubit/months_cubit.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'di/injection_container.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MyWalletApp extends StatelessWidget {
  const MyWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => getIt<AuthCubit>()..startListening()),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..loadCategories()),
        BlocProvider(create: (_) => getIt<MonthsCubit>()..loadMonths()),
        BlocProvider(create: (_) => getIt<ExpensesCubit>()..loadExpenses()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'My Wallet | محفظتي',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: getIt<AppRouter>().router,
          );
        },
      ),
    );
  }
}
