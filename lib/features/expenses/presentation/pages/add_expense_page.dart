import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../months/presentation/cubit/months_cubit.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expenses_cubit.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, this.expense});

  final Expense? expense;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _amountController.text = expense.amount.toStringAsFixed(0);
      _noteController.text = expense.note;
      _selectedDate = expense.date;
      _selectedCategoryId = expense.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesCubit>().state.categories;
    final month = context.watch<MonthsCubit>().state.selectedMonth;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل المصروف' : 'إضافة مصروف'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: () async {
                await context
                    .read<ExpensesCubit>()
                    .deleteExpense(widget.expense!.id);
                if (context.mounted) {
                  context.pop();
                }
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _amountController,
                  label: 'المبلغ',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل المبلغ';
                    }
                    if (double.tryParse(value) == null) {
                      return 'أدخل رقمًا صحيحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategoryId = value),
                  validator: (value) => value == null ? 'اختر تصنيفًا' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _noteController,
                  label: 'ملاحظة',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: TextEditingController(
                    text: Formatters.shortDate.format(_selectedDate),
                  ),
                  label: 'التاريخ',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_today_rounded),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _isEditing ? 'حفظ التعديلات' : 'إضافة المصروف',
                  icon: Icons.check_circle_rounded,
                  onPressed: month == null
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final expense = Expense(
                              id: widget.expense?.id ?? const Uuid().v4(),
                              monthId: month.id,
                              categoryId: _selectedCategoryId!,
                              amount: double.parse(_amountController.text),
                              note: _noteController.text.trim(),
                              date: _selectedDate,
                              createdAt: widget.expense?.createdAt ?? DateTime.now(),
                            );
                            await context.read<ExpensesCubit>().saveExpense(expense);
                            if (context.mounted) {
                              context.pop();
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }
}
