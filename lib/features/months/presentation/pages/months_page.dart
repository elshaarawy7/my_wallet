import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../expenses/presentation/cubit/expenses_cubit.dart';
import '../../domain/entities/wallet_month.dart';
import '../cubit/months_cubit.dart';

class MonthsPage extends StatelessWidget {
  const MonthsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأشهر')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMonthDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('شهر جديد'),
      ),
      body: BlocBuilder<MonthsCubit, MonthsState>(
        builder: (context, state) {
          if (state.months.isEmpty) {
            return const EmptyStateView(
              title: 'لا توجد شهور',
              message: 'أنشئ شهرًا جديدًا للبدء في تسجيل المصروفات.',
            );
          }

          final expenses = context.watch<ExpensesCubit>().state.expenses;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: state.months.length,
            itemBuilder: (context, index) {
              final month = state.months[index];
              final totalSpent = expenses
                  .where((expense) => expense.monthId == month.id)
                  .fold<double>(0, (sum, expense) => sum + expense.amount);
              final remaining = month.monthlyIncome - totalSpent;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.read<MonthsCubit>().selectMonth(month.id),
                  leading: CircleAvatar(
                    child: Icon(
                      month.id == state.selectedMonthId
                          ? Icons.check_rounded
                          : Icons.calendar_month_rounded,
                    ),
                  ),
                  title: Text(month.name),
                  subtitle: Text(
                    'الدخل: ${month.monthlyIncome.toStringAsFixed(0)} ج.م • المتبقي: ${remaining.toStringAsFixed(0)} ج.م',
                  ),
                  trailing: Text('${totalSpent.toStringAsFixed(0)} ج.م'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddMonthDialog(BuildContext context) async {
    final incomeController = TextEditingController(
      text: AppConstants.defaultBudget.toStringAsFixed(0),
    );
    var selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة شهر'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(DateFormat('MMMM yyyy', 'ar').format(selectedDate)),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  TextField(
                    controller: incomeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الدخل الشهري'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () async {
                    final month = WalletMonth(
                      id: '${selectedDate.year}-${selectedDate.month}-${const Uuid().v1()}',
                      name: DateFormat('MMMM yyyy', 'ar').format(selectedDate),
                      year: selectedDate.year,
                      monthNumber: selectedDate.month,
                      monthlyIncome: double.tryParse(incomeController.text) ??
                          AppConstants.defaultBudget,
                      createdAt: DateTime(selectedDate.year, selectedDate.month, 1),
                    );
                    await context.read<MonthsCubit>().saveMonth(month);
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
