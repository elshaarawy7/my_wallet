import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../categories/domain/entities/expense_category.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/cubit/expenses_cubit.dart';
import '../../../months/domain/entities/wallet_month.dart';
import '../../../months/presentation/cubit/months_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محفظتي'),
        actions: [
          IconButton(
            onPressed: () => context.push('/categories'),
            icon: const Icon(Icons.add_card_rounded),
          ),
        ],
      ),
      body: BlocBuilder<MonthsCubit, MonthsState>(
        builder: (context, monthsState) {
          return BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, categoriesState) {
              return BlocBuilder<ExpensesCubit, ExpensesState>(
                builder: (context, expensesState) {
                  final month = monthsState.selectedMonth;
                  if (month == null) {
                    return const EmptyStateView(
                      title: 'لا يوجد شهر نشط',
                      message: 'أنشئ شهرًا جديدًا من شاشة الأشهر للبدء.',
                    );
                  }

                  final categories = categoriesState.categories;
                  final monthExpenses = expensesState.expenses
                      .where((expense) => expense.monthId == month.id)
                      .toList();
                  final totalSpent = monthExpenses.fold<double>(
                    0,
                    (sum, expense) => sum + expense.amount,
                  );
                  final remaining = month.monthlyIncome - totalSpent;
                  final progress = month.monthlyIncome <= 0
                      ? 0.0
                      : (totalSpent / month.monthlyIncome).clamp(0.0, 1.0);

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<MonthsCubit>().loadMonths();
                      await context.read<CategoriesCubit>().loadCategories();
                      await context.read<ExpensesCubit>().loadExpenses();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                _IncomeSummaryCard(
                                  month: month,
                                  totalSpent: totalSpent,
                                  remaining: remaining,
                                  progress: progress,
                                  onEditIncome: () => _showIncomeSheet(context, month),
                                ),
                                const SizedBox(height: 18),
                                _SectionHeader(
                                  title: 'التصنيفات',
                                  actionLabel: 'إدارة',
                                  onPressed: () => context.push('/categories'),
                                ),
                                const SizedBox(height: 10),
                                _CategoriesPanel(
                                  categories: categories,
                                  expenses: monthExpenses,
                                ),
                                const SizedBox(height: 18),
                                _SectionHeader(
                                  title: 'آخر العمليات',
                                  actionLabel: 'إضافة',
                                  onPressed: () => context.push('/expense'),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        if (monthExpenses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyStateView(
                              title: 'لا توجد عمليات بعد',
                              message: 'اضغط على أي تصنيف لإضافة أول مصروف يومي.',
                              icon: Icons.receipt_long_rounded,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                            sliver: SliverList.builder(
                              itemCount: monthExpenses.take(8).length,
                              itemBuilder: (context, index) {
                                final expense = monthExpenses[index];
                                return _ExpenseTile(
                                  expense: expense,
                                  category: categories
                                      .where((item) => item.id == expense.categoryId)
                                      .firstOrNull,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showIncomeSheet(BuildContext context, WalletMonth month) async {
    final controller = TextEditingController(
      text: month.monthlyIncome.toStringAsFixed(0),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تعديل الدخل الشهري',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الدخل الشهري',
                  prefixText: 'ج.م ',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value < 0) {
                    return;
                  }
                  await context.read<MonthsCubit>().updateMonthlyIncome(
                        monthId: month.id,
                        monthlyIncome: value,
                      );
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
                child: const Text('حفظ الدخل'),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _IncomeSummaryCard extends StatelessWidget {
  const _IncomeSummaryCard({
    required this.month,
    required this.totalSpent,
    required this.remaining,
    required this.progress,
    required this.onEditIncome,
  });

  final WalletMonth month;
  final double totalSpent;
  final double remaining;
  final double progress;
  final VoidCallback onEditIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryGreen,
            AppConstants.primaryGreen.withOpacity(0.88),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        month.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الدخل الشهري',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.14),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onEditIncome,
                  icon: const Icon(Icons.edit_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Formatters.currency.format(month.monthlyIncome),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: Colors.white.withOpacity(0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MoneyInfoTile(
                    label: 'المصروفات',
                    value: Formatters.currency.format(totalSpent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MoneyInfoTile(
                    label: 'المتبقي',
                    value: Formatters.currency.format(remaining),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyInfoTile extends StatelessWidget {
  const _MoneyInfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _CategoriesPanel extends StatelessWidget {
  const _CategoriesPanel({
    required this.categories,
    required this.expenses,
  });

  final List<ExpenseCategory> categories;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'التصنيف',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  'المبلغ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 34),
              ],
            ),
          ),
          const Divider(height: 1),
          ...List.generate(categories.length, (index) {
            final category = categories[index];
            final spent = expenses
                .where((expense) => expense.categoryId == category.id)
                .fold<double>(0, (sum, expense) => sum + expense.amount);

            return Column(
              children: [
                _CategoryRow(
                  category: category,
                  amount: spent,
                ),
                if (index != categories.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.withOpacity(0.15),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
  });

  final ExpenseCategory category;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return InkWell(
      onTap: () => context.push(
        '/expense',
        extra: <String, dynamic>{'categoryId': category.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: color.withOpacity(0.14),
              child: Icon(
                IconMapper.fromKey(category.iconKey),
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              Formatters.currency.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            PopupMenuButton<_CategoryAction>(
              icon: const Icon(Icons.more_horiz_rounded, size: 18),
              onSelected: (action) {
                switch (action) {
                  case _CategoryAction.addExpense:
                    context.push(
                      '/expense',
                      extra: <String, dynamic>{'categoryId': category.id},
                    );
                    break;
                  case _CategoryAction.edit:
                    _showCategoryDialog(context, category: category);
                    break;
                  case _CategoryAction.delete:
                    context.read<CategoriesCubit>().deleteCategory(category.id);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _CategoryAction.addExpense,
                  child: Text('إضافة مصروف'),
                ),
                PopupMenuItem(
                  value: _CategoryAction.edit,
                  child: Text('تعديل التصنيف'),
                ),
                PopupMenuItem(
                  value: _CategoryAction.delete,
                  child: Text('حذف التصنيف'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    required ExpenseCategory category,
  }) async {
    final nameController = TextEditingController(text: category.name);
    var iconKey = category.iconKey;
    var colorValue = category.colorValue;
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
              title: const Text('تعديل التصنيف'),
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
                      runSpacing: 8,
                      children: IconMapper.icons.keys.map((key) {
                        return ChoiceChip(
                          label: Icon(IconMapper.fromKey(key)),
                          selected: iconKey == key,
                          onSelected: (_) => setState(() => iconKey = key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: palette.map((color) {
                        return ChoiceChip(
                          label: CircleAvatar(radius: 10, backgroundColor: Color(color)),
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
                    final trimmedName = nameController.text.trim();
                    if (trimmedName.isEmpty) {
                      return;
                    }
                    await context.read<CategoriesCubit>().saveCategory(
                          ExpenseCategory(
                            id: category.id,
                            name: trimmedName,
                            iconKey: iconKey,
                            colorValue: colorValue,
                            isDefault: category.isDefault,
                          ),
                        );
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

enum _CategoryAction { addExpense, edit, delete }

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.category});

  final Expense expense;
  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category?.colorValue ?? 0xFFBDBDBD);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () => context.push('/expense', extra: expense),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            IconMapper.fromKey(category?.iconKey ?? 'shopping_bag'),
            color: color,
            size: 16,
          ),
        ),
        title: Text(
          expense.note.isEmpty ? category?.name ?? 'مصروف' : expense.note,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        trailing: Text(
          Formatters.currency.format(expense.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        subtitle: Text(
          '${category?.name ?? 'أخرى'} • ${Formatters.shortDate.format(expense.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
