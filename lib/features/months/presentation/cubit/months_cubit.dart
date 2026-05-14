import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wallet_month.dart';
import '../../domain/repositories/months_repository.dart';

class MonthsState {
  const MonthsState({
    this.months = const [],
    this.selectedMonthId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<WalletMonth> months;
  final String? selectedMonthId;
  final bool isLoading;
  final String? errorMessage;

  WalletMonth? get selectedMonth {
    if (selectedMonthId == null) {
      return months.isEmpty ? null : months.first;
    }

    return months.where((month) => month.id == selectedMonthId).firstOrNull ??
        (months.isEmpty ? null : months.first);
  }

  MonthsState copyWith({
    List<WalletMonth>? months,
    String? selectedMonthId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MonthsState(
      months: months ?? this.months,
      selectedMonthId: selectedMonthId ?? this.selectedMonthId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class MonthsCubit extends Cubit<MonthsState> {
  MonthsCubit(this._repository) : super(const MonthsState());

  final MonthsRepository _repository;

  Future<void> loadMonths() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.seedCurrentMonth();
      final months = await _repository.getMonths();
      final selectedMonthId =
          await _repository.getSelectedMonthId() ?? months.firstOrNull?.id;
      emit(
        state.copyWith(
          isLoading: false,
          months: months,
          selectedMonthId: selectedMonthId,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'تعذر تحميل الشهور.',
        ),
      );
    }
  }

  Future<void> saveMonth(WalletMonth month) async {
    await _repository.saveMonth(month);
    await _repository.setSelectedMonthId(month.id);
    await loadMonths();
  }

  Future<void> selectMonth(String monthId) async {
    await _repository.setSelectedMonthId(monthId);
    emit(state.copyWith(selectedMonthId: monthId));
  }
}
