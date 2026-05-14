import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/categories/data/repositories/categories_local_repository.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/expenses/data/repositories/expenses_local_repository.dart';
import '../../features/expenses/domain/repositories/expenses_repository.dart';
import '../../features/expenses/presentation/cubit/expenses_cubit.dart';
import '../../features/months/data/repositories/months_local_repository.dart';
import '../../features/months/domain/repositories/months_repository.dart';
import '../../features/months/presentation/cubit/months_cubit.dart';
import '../../features/settings/data/repositories/settings_local_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../router/app_router.dart';
import '../services/hive_service.dart';
import '../services/shared_prefs_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({required bool firebaseReady}) async {
  final prefsService = await SharedPrefsService.create();
  final hiveService = await HiveService.create();
  GoogleSignIn? googleSignIn;

  if (firebaseReady) {
    googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
  }

  getIt
    ..registerSingleton<bool>(firebaseReady, instanceName: 'firebaseReady')
    ..registerSingleton<SharedPrefsService>(prefsService)
    ..registerSingleton<HiveService>(hiveService)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsLocalRepository(getIt<SharedPrefsService>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(
        firebaseAuth: firebaseReady ? FirebaseAuth.instance : null,
        googleSignIn: googleSignIn,
        firebaseReady: getIt<bool>(instanceName: 'firebaseReady'),
      ),
    )
    ..registerLazySingleton<CategoriesRepository>(
      () => CategoriesLocalRepository(getIt<HiveService>()),
    )
    ..registerLazySingleton<MonthsRepository>(
      () => MonthsLocalRepository(
        getIt<HiveService>(),
        getIt<SharedPrefsService>(),
      ),
    )
    ..registerLazySingleton<ExpensesRepository>(
      () => ExpensesLocalRepository(getIt<HiveService>()),
    )
    ..registerFactory(() => SettingsCubit(getIt<SettingsRepository>()))
    ..registerFactory(() => AuthCubit(getIt<AuthRepository>()))
    ..registerFactory(() => CategoriesCubit(getIt<CategoriesRepository>()))
    ..registerFactory(() => MonthsCubit(getIt<MonthsRepository>()))
    ..registerFactory(() => ExpensesCubit(getIt<ExpensesRepository>()))
    ..registerLazySingleton(() => AppRouter())
    ..registerLazySingleton<GoRouter>(() => getIt<AppRouter>().router);
}
