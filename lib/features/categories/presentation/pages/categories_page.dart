import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/icon_mapper.dart';
import '../../../categories/domain/entities/expense_category.dart';
import '../cubit/categories_cubit.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تخصيص التصنيفات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('تصنيف جديد'),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(category.colorValue).withOpacity(0.15),
                    child: Icon(
                      IconMapper.fromKey(category.iconKey),
                      color: Color(category.colorValue),
                    ),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showCategoryDialog(context, category: category),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      if (!category.isDefault)
                        IconButton(
                          onPressed: () => context
                              .read<CategoriesCubit>()
                              .deleteCategory(category.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    ExpenseCategory? category,
  }) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    var iconKey = category?.iconKey ?? 'shopping_bag';
    var colorValue = category?.colorValue ?? 0xFF26A69A;
    const palette = [
      0xFF26A69A,
      0xFFE57373,
      0xFF64B5F6,
      0xFFFFB74D,
      0xFF9575CD,
      0xFFF06292,
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'تصنيف جديد' : 'تعديل التصنيف'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'اسم التصنيف'),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: IconMapper.icons.keys.map((key) {
                        final selected = iconKey == key;
                        return ChoiceChip(
                          label: Icon(IconMapper.fromKey(key)),
                          selected: selected,
                          onSelected: (_) => setState(() => iconKey = key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: palette.map((color) {
                        return ChoiceChip(
                          label: _ColorDot(colorValue: color),
                          selected: colorValue == color,
                          onSelected: (_) => setState(() => colorValue = color),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () async {
                    final item = ExpenseCategory(
                      id: category?.id ?? const Uuid().v4(),
                      name: nameController.text.trim(),
                      iconKey: iconKey,
                      colorValue: colorValue,
                      isDefault: category?.isDefault ?? false,
                    );
                    await context.read<CategoriesCubit>().saveCategory(item);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.colorValue});

  final int colorValue;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Color(colorValue),
    );
  }
}
