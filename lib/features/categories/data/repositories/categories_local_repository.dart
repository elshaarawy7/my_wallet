import 'package:flutter/material.dart';

import '../../../../core/services/hive_service.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../models/expense_category_model.dart';

class CategoriesLocalRepository implements CategoriesRepository {
  CategoriesLocalRepository(this._hiveService);

  final HiveService _hiveService;

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _hiveService.categoriesBox.delete(categoryId);
  }

  @override
  Future<List<ExpenseCategory>> getCategories() async {
    return _hiveService.categoriesBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> saveCategory(ExpenseCategory category) async {
    final model = ExpenseCategoryModel.fromEntity(category);
    await _hiveService.categoriesBox.put(model.id, model);
  }

  @override
  Future<void> seedDefaultCategories() async {
    if (_hiveService.categoriesBox.isNotEmpty) {
      return;
    }

    final defaults = [
      const ExpenseCategoryModel(
        id: 'food',
        name: 'الأكل',
        iconKey: 'restaurant',
        colorValue: 0xFFE57373,
        isDefault: true,
      ),
      const ExpenseCategoryModel(
        id: 'drinks',
        name: 'المشروبات',
        iconKey: 'coffee',
        colorValue: 0xFF64B5F6,
        isDefault: true,
      ),
      const ExpenseCategoryModel(
        id: 'transport',
        name: 'المواصلات',
        iconKey: 'directions_bus',
        colorValue: 0xFFFFB74D,
        isDefault: true,
      ),
      const ExpenseCategoryModel(
        id: 'football',
        name: 'الكورة',
        iconKey: 'sports_soccer',
        colorValue: 0xFF81C784,
        isDefault: true,
      ),
      const ExpenseCategoryModel(
        id: 'bills',
        name: 'الالتزامات',
        iconKey: 'payments',
        colorValue: 0xFF9575CD,
        isDefault: true,
      ),
      const ExpenseCategoryModel(
        id: 'fun',
        name: 'الرفاهيات',
        iconKey: 'celebration',
        colorValue: 0xFFF06292,
        isDefault: true,
      ),
    ];

    for (final category in defaults) {
      await _hiveService.categoriesBox.put(category.id, category);
    }
  }
}
