import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';

class ExpensesState {
  const ExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Expense> expenses;
  final bool isLoading;
  final String? errorMessage;

  ExpensesState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ExpensesCubit extends Cubit<ExpensesState> {
  ExpensesCubit(this._repository) : super(const ExpensesState());

  final ExpensesRepository _repository;

  Future<void> loadExpenses() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final expenses = await _repository.getExpenses();
      emit(state.copyWith(isLoading: false, expenses: expenses));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'تعذر تحميل المصروفات.',
        ),
      );
    }
  }

  Future<void> saveExpense(Expense expense) async {
    await _repository.saveExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String expenseId) async {
    await _repository.deleteExpense(expenseId);
    await loadExpenses();
  }
}
