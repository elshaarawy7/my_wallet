import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/categories_repository.dart';

class CategoriesState {
  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ExpenseCategory> categories;
  final bool isLoading;
  final String? errorMessage;

  CategoriesState copyWith({
    List<ExpenseCategory>? categories,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState());

  final CategoriesRepository _repository;

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.seedDefaultCategories();
      final categories = await _repository.getCategories();
      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'تعذر تحميل التصنيفات.',
        ),
      );
    }
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    await _repository.saveCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    await loadCategories();
  }
}
