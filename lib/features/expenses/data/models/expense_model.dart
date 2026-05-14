import 'package:hive/hive.dart';

import '../../domain/entities/expense.dart';

@HiveType(typeId: 3)
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.monthId,
    required super.categoryId,
    required super.amount,
    required super.note,
    required super.date,
    required super.createdAt,
  });

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      monthId: entity.monthId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      note: entity.note,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }
}

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 3;

  @override
  ExpenseModel read(BinaryReader reader) {
    return ExpenseModel(
      id: reader.readString(),
      monthId: reader.readString(),
      categoryId: reader.readString(),
      amount: reader.readDouble(),
      note: reader.readString(),
      date: DateTime.parse(reader.readString()),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.monthId)
      ..writeString(obj.categoryId)
      ..writeDouble(obj.amount)
      ..writeString(obj.note)
      ..writeString(obj.date.toIso8601String())
      ..writeString(obj.createdAt.toIso8601String());
  }
}
