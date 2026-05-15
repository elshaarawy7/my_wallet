import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../categories/domain/entities/expense_category.dart';
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
                  message: 'أنشئ شهرًا جديدًا ثم أضف مصروفات لعرض الإحصائيات.',
                );
              }

              final monthExpenses = expensesState.expenses
                  .where((expense) => expense.monthId == month.id)
                  .toList();
              if (monthExpenses.isEmpty) {
                return const EmptyStateView(
                  title: 'الإحصائيات فارغة',
                  message: 'بعد تسجيل مصروفاتك ستظهر الرسوم والتحليلات هنا.',
                  icon: Icons.pie_chart_rounded,
                );
              }

              final categories = context.read<CategoriesCubit>().state.categories;
              final totalsByCategory = <ExpenseCategory, double>{};

              for (final category in categories) {
                final total = monthExpenses
                    .where((expense) => expense.categoryId == category.id)
                    .fold<double>(0, (sum, expense) => sum + expense.amount);
                if (total > 0) {
                  totalsByCategory[category] = total;
                }
              }

              final topCategoryEntry = totalsByCategory.entries.isEmpty
                  ? null
                  : totalsByCategory.entries.reduce(
                      (current, next) => current.value >= next.value ? current : next,
                    );

              final recentMonths = monthsState.months.take(6).toList().reversed.toList();
              final barGroups = recentMonths.asMap().entries.map((entry) {
                final total = expensesState.expenses
                    .where((expense) => expense.monthId == entry.value.id)
                    .fold<double>(0, (sum, expense) => sum + expense.amount);
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: total,
                      width: 18,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                );
              }).toList();

              final pieSections = totalsByCategory.entries.map((entry) {
                return PieChartSectionData(
                  color: Color(entry.key.colorValue),
                  value: entry.value,
                  title: entry.key.name,
                  radius: 86,
                );
              }).toList();

              final totalSpent = monthExpenses.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatsInfoCard(
                          title: 'إجمالي المصروفات',
                          value: Formatters.currency.format(totalSpent),
                          icon: Icons.payments_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatsInfoCard(
                          title: 'أعلى تصنيف',
                          value: topCategoryEntry?.key.name ?? 'لا يوجد',
                          icon: Icons.emoji_events_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: SizedBox(
                        height: 260,
                        child: PieChart(PieChartData(sections: pieSections)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: SizedBox(
                        height: 220,
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
                                        recentMonths[value.toInt()].monthNumber.toString(),
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
                  ...totalsByCategory.entries.map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(entry.key.colorValue).withOpacity(0.15),
                        child: Icon(
                          Icons.pie_chart_outline_rounded,
                          color: Color(entry.key.colorValue),
                        ),
                      ),
                      title: Text(entry.key.name),
                      trailing: Text(Formatters.currency.format(entry.value)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsInfoCard extends StatelessWidget {
  const _StatsInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
