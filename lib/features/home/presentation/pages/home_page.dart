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
            icon: const Icon(Icons.tune_rounded),
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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: [
                        _IncomeSummaryCard(
                          month: month,
                          totalSpent: totalSpent,
                          remaining: remaining,
                          progress: progress,
                          onEditIncome: () => _showIncomeSheet(context, month),
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(
                          title: 'تصنيفات المصروفات',
                          actionLabel: 'الأشهر',
                          onPressed: () => context.go('/months'),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final categoryTotal = monthExpenses
                                .where((expense) => expense.categoryId == category.id)
                                .fold<double>(0, (sum, expense) => sum + expense.amount);

                            return _CategoryCard(
                              category: category,
                              amount: categoryTotal,
                              onTap: () => context.push(
                                '/expense',
                                extra: <String, dynamic>{'categoryId': category.id},
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: 'آخر العمليات',
                          actionLabel: 'إضافة مصروف',
                          onPressed: () => context.push('/expense'),
                        ),
                        const SizedBox(height: 12),
                        if (monthExpenses.isEmpty)
                          const EmptyStateView(
                            title: 'لا توجد مصروفات بعد',
                            message: 'اضغط على أي تصنيف بالأعلى لإضافة أول مصروف يومي.',
                            icon: Icons.receipt_long_rounded,
                          )
                        else
                          ...monthExpenses.take(8).map(
                                (expense) => _ExpenseTile(
                                  expense: expense,
                                  category: categories
                                      .where((item) => item.id == expense.categoryId)
                                      .firstOrNull,
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
                      fontWeight: FontWeight.w700,
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Card(
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الدخل الشهري',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onEditIncome,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                Formatters.currency.format(month.monthlyIncome),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppConstants.primaryGreen,
                    ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MoneyInfoTile(
                      label: 'المصروفات',
                      value: Formatters.currency.format(totalSpent),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MoneyInfoTile(
                      label: 'المتبقي',
                      value: Formatters.currency.format(remaining),
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyInfoTile extends StatelessWidget {
  const _MoneyInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.amount,
    required this.onTap,
  });

  final ExpenseCategory category;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.14),
                child: Icon(IconMapper.fromKey(category.iconKey), color: color),
              ),
              const Spacer(),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.currency.format(amount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.category});

  final Expense expense;
  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category?.colorValue ?? 0xFFBDBDBD);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => context.push('/expense', extra: expense),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            IconMapper.fromKey(category?.iconKey ?? 'shopping_bag'),
            color: color,
          ),
        ),
        title: Text(expense.note.isEmpty ? category?.name ?? 'مصروف' : expense.note),
        subtitle: Text(
          '${category?.name ?? 'أخرى'} • ${Formatters.shortDate.format(expense.date)}',
        ),
        trailing: Text(
          Formatters.currency.format(expense.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
