import 'package:equatable/equatable.dart';

class WalletMonth extends Equatable {
  const WalletMonth({
    required this.id,
    required this.name,
    required this.year,
    required this.monthNumber,
    required this.monthlyIncome,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int year;
  final int monthNumber;
  final double monthlyIncome;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        name,
        year,
        monthNumber,
        monthlyIncome,
        createdAt,
      ];
}
