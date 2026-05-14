import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            onPressed: () => context.push('/categories'),
            icon: const Icon(Icons.category_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expense'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('مصروف جديد'),
      ),
      body: BlocBuilder<MonthsCubit, MonthsState>(
        builder: (context, monthsState) {
          return BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, categoriesState) {
              return BlocBuilder<ExpensesCubit, ExpensesState>(
                builder: (context, expensesState) {
                  final selectedMonth = monthsState.selectedMonth;
                  final categories = categoriesState.categories;
                  final expenses = _filterExpenses(
                    selectedMonth,
                    expensesState.expenses,
                  );

                  if (selectedMonth == null) {
                    return const EmptyStateView(
                      title: 'لا يوجد شهر نشط',
                      message: 'أنشئ شهرًا جديدًا من شاشة الأشهر لتبدأ.',
                    );
                  }

                  final total = expenses.fold<double>(
                    0,
                    (sum, expense) => sum + expense.amount,
                  );
                  final progress = selectedMonth.budget == 0
                      ? 0.0
                      : (total / selectedMonth.budget).clamp(0.0, 1.0);

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<MonthsCubit>().loadMonths();
                      await context.read<CategoriesCubit>().loadCategories();
                      await context.read<ExpensesCubit>().loadExpenses();
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      children: [
                        _MonthSummaryCard(
                          month: selectedMonth,
                          total: total,
                          progress: progress,
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: 'التصنيفات',
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
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final spent = expenses
                                .where((expense) => expense.categoryId == category.id)
                                .fold<double>(0, (sum, expense) => sum + expense.amount);

                            return _CategoryCard(
                              category: category,
                              amount: spent,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(title: 'آخر المصروفات'),
                        const SizedBox(height: 12),
                        if (expenses.isEmpty)
                          const EmptyStateView(
                            title: 'لسه ما أضفتش مصروفات',
                            message: 'ابدأ بإضافة أول مصروف وسيظهر هنا مباشرة.',
                            icon: Icons.receipt_long_rounded,
                          )
                        else
                          ...expenses.take(6).map(
                                (expense) => _ExpenseTile(
                                  expense: expense,
                                  category: categories.where((item) {
                                    return item.id == expense.categoryId;
                                  }).firstOrNull,
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

  List<Expense> _filterExpenses(WalletMonth? month, List<Expense> expenses) {
    if (month == null) {
      return [];
    }

    return expenses.where((expense) => expense.monthId == month.id).toList();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({
    required this.month,
    required this.total,
    required this.progress,
  });

  final WalletMonth month;
  final double total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'شهر ${month.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.currency.format(total),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text('الميزانية: ${Formatters.currency.format(month.budget)}'),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('استهلاك الميزانية: ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
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
                  fontWeight: FontWeight.w700,
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
  const _CategoryCard({required this.category, required this.amount});

  final ExpenseCategory category;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
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
            Text(Formatters.currency.format(amount)),
          ],
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.push('/expense', extra: expense),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            IconMapper.fromKey(category?.iconKey ?? 'shopping_bag'),
            color: color,
          ),
        ),
        title: Text(category?.name ?? 'تصنيف'),
        subtitle: Text(
          expense.note.isEmpty
              ? Formatters.shortDate.format(expense.date)
              : '${expense.note} • ${Formatters.shortDate.format(expense.date)}',
        ),
        trailing: Text(
          Formatters.currency.format(expense.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
