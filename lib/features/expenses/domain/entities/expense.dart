import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.monthId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String monthId;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, monthId, categoryId, amount, note, date, createdAt];
}
