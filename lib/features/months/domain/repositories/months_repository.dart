import '../entities/wallet_month.dart';

abstract class MonthsRepository {
  Future<List<WalletMonth>> getMonths();

  Future<void> saveMonth(WalletMonth month);

  Future<void> updateMonthlyIncome({
    required String monthId,
    required double monthlyIncome,
  });

  Future<String?> getSelectedMonthId();

  Future<void> setSelectedMonthId(String monthId);

  Future<void> seedCurrentMonth();
}
