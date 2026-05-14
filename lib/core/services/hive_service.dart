import 'package:hive_flutter/hive_flutter.dart';

import '../../features/categories/data/models/expense_category_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/months/data/models/wallet_month_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  HiveService._({
    required this.categoriesBox,
    required this.monthsBox,
    required this.expensesBox,
  });

  final Box<ExpenseCategoryModel> categoriesBox;
  final Box<WalletMonthModel> monthsBox;
  final Box<ExpenseModel> expensesBox;

  static Future<HiveService> create() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseCategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WalletMonthModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

    final categoriesBox = await Hive.openBox<ExpenseCategoryModel>(
      AppConstants.categoriesBox,
    );
    final monthsBox = await Hive.openBox<WalletMonthModel>(
      AppConstants.monthsBox,
    );
    final expensesBox = await Hive.openBox<ExpenseModel>(
      AppConstants.expensesBox,
    );

    return HiveService._(
      categoriesBox: categoriesBox,
      monthsBox: monthsBox,
      expensesBox: expensesBox,
    );
  }
}
