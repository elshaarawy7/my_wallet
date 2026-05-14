import 'package:hive/hive.dart';

import '../../domain/entities/expense_category.dart';

@HiveType(typeId: 1)
class ExpenseCategoryModel extends ExpenseCategory {
  const ExpenseCategoryModel({
    required super.id,
    required super.name,
    required super.iconKey,
    required super.colorValue,
    super.isDefault,
  });

  factory ExpenseCategoryModel.fromEntity(ExpenseCategory entity) {
    return ExpenseCategoryModel(
      id: entity.id,
      name: entity.name,
      iconKey: entity.iconKey,
      colorValue: entity.colorValue,
      isDefault: entity.isDefault,
    );
  }
}

class ExpenseCategoryModelAdapter extends TypeAdapter<ExpenseCategoryModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseCategoryModel read(BinaryReader reader) {
    return ExpenseCategoryModel(
      id: reader.readString(),
      name: reader.readString(),
      iconKey: reader.readString(),
      colorValue: reader.readInt(),
      isDefault: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseCategoryModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.iconKey)
      ..writeInt(obj.colorValue)
      ..writeBool(obj.isDefault);
  }
}
