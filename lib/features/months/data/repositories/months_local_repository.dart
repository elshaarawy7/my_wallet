import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/entities/wallet_month.dart';
import '../../domain/repositories/months_repository.dart';
import '../models/wallet_month_model.dart';

class MonthsLocalRepository implements MonthsRepository {
  MonthsLocalRepository(this._hiveService, this._prefsService);

  final HiveService _hiveService;
  final SharedPrefsService _prefsService;

  @override
  Future<List<WalletMonth>> getMonths() async {
    final months = _hiveService.monthsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return months;
  }

  @override
  Future<String?> getSelectedMonthId() async {
    return _prefsService.getString(AppConstants.selectedMonthKey);
  }

  @override
  Future<void> saveMonth(WalletMonth month) async {
    final model = WalletMonthModel.fromEntity(month);
    await _hiveService.monthsBox.put(model.id, model);
  }

  @override
  Future<void> seedCurrentMonth() async {
    if (_hiveService.monthsBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final month = WalletMonthModel(
      id: '${now.year}-${now.month}',
      name: DateFormat('MMMM yyyy', 'ar').format(now),
      year: now.year,
      monthNumber: now.month,
      budget: AppConstants.defaultBudget,
      createdAt: DateTime(now.year, now.month, 1),
    );

    await _hiveService.monthsBox.put(month.id, month);
    await setSelectedMonthId(month.id);
  }

  @override
  Future<void> setSelectedMonthId(String monthId) async {
    await _prefsService.setString(AppConstants.selectedMonthKey, monthId);
  }
}
