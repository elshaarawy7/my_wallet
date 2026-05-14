import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../expenses/presentation/cubit/expenses_cubit.dart';
import '../../../months/presentation/cubit/months_cubit.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: BlocBuilder<MonthsCubit, MonthsState>(
        builder: (context, monthsState) {
          return BlocBuilder<ExpensesCubit, ExpensesState>(
            builder: (context, expensesState) {
              final month = monthsState.selectedMonth;
              if (month == null) {
                return const EmptyStateView(
                  title: 'لا توجد بيانات',
                  message: 'أنشئ شهرًا جديدًا وأضف مصروفات لعرض الإحصائيات.',
                );
              }

              final expenses = expensesState.expenses
                  .where((expense) => expense.monthId == month.id)
                  .toList();

              if (expenses.isEmpty) {
                return const EmptyStateView(
                  title: 'الإحصائيات ما زالت فارغة',
                  message: 'بعد إضافة المصروفات ستظهر الرسوم هنا تلقائيًا.',
                  icon: Icons.bar_chart_rounded,
                );
              }

              final categories = context.read<CategoriesCubit>().state.categories;
              final totalsByCategory = <String, double>{};

              for (final expense in expenses) {
                totalsByCategory.update(
                  expense.categoryId,
                  (value) => value + expense.amount,
                  ifAbsent: () => expense.amount,
                );
              }

              final recentMonths = monthsState.months.take(6).toList().reversed.toList();
              final barGroups = recentMonths.asMap().entries.map((entry) {
                final monthTotal = expensesState.expenses
                    .where((expense) => expense.monthId == entry.value.id)
                    .fold<double>(0, (sum, expense) => sum + expense.amount);

                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: monthTotal,
                      width: 18,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                );
              }).toList();

              final pieSections = totalsByCategory.entries.map((entry) {
                final matches = categories.where((item) => item.id == entry.key);
                final category = matches.firstOrNull;
                if (category == null) {
                  return null;
                }
                return PieChartSectionData(
                  color: Color(category.colorValue),
                  value: entry.value,
                  title: category.name,
                  radius: 90,
                );
              }).whereType<PieChartSectionData>().toList();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 240,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= recentMonths.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        recentMonths[value.toInt()].monthNumber
                                            .toString(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: barGroups,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 280,
                        child: PieChart(PieChartData(sections: pieSections)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...totalsByCategory.entries.map((entry) {
                    final matches =
                        categories.where((item) => item.id == entry.key);
                    final category = matches.firstOrNull;
                    if (category == null) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Color(category.colorValue)),
                      title: Text(category.name),
                      trailing: Text(Formatters.currency.format(entry.value)),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
