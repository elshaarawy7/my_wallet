import 'package:equatable/equatable.dart';

class ExpenseCategory extends Equatable {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final bool isDefault;

  @override
  List<Object?> get props => [id, name, iconKey, colorValue, isDefault];
}
