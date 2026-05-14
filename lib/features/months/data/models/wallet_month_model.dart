import 'package:hive/hive.dart';

import '../../domain/entities/wallet_month.dart';

@HiveType(typeId: 2)
class WalletMonthModel extends WalletMonth {
  const WalletMonthModel({
    required super.id,
    required super.name,
    required super.year,
    required super.monthNumber,
    required super.budget,
    required super.createdAt,
  });

  factory WalletMonthModel.fromEntity(WalletMonth entity) {
    return WalletMonthModel(
      id: entity.id,
      name: entity.name,
      year: entity.year,
      monthNumber: entity.monthNumber,
      budget: entity.budget,
      createdAt: entity.createdAt,
    );
  }
}

class WalletMonthModelAdapter extends TypeAdapter<WalletMonthModel> {
  @override
  final int typeId = 2;

  @override
  WalletMonthModel read(BinaryReader reader) {
    return WalletMonthModel(
      id: reader.readString(),
      name: reader.readString(),
      year: reader.readInt(),
      monthNumber: reader.readInt(),
      budget: reader.readDouble(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, WalletMonthModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeInt(obj.year)
      ..writeInt(obj.monthNumber)
      ..writeDouble(obj.budget)
      ..writeString(obj.createdAt.toIso8601String());
  }
}
