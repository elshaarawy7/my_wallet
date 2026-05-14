import '../../../../core/services/hive_service.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../models/expense_model.dart';

class ExpensesLocalRepository implements ExpensesRepository {
  ExpensesLocalRepository(this._hiveService);

  final HiveService _hiveService;

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _hiveService.expensesBox.delete(expenseId);
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final expenses = _hiveService.expensesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _hiveService.expensesBox.put(model.id, model);
  }
}
