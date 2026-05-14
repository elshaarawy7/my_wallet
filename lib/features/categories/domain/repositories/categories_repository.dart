import '../entities/expense_category.dart';

abstract class CategoriesRepository {
  Future<List<ExpenseCategory>> getCategories();

  Future<void> saveCategory(ExpenseCategory category);

  Future<void> deleteCategory(String categoryId);

  Future<void> seedDefaultCategories();
}
