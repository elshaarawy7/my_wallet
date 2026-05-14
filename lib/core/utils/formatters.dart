import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'ar',
    symbol: 'ج.م',
    decimalDigits: 0,
  );

  static final DateFormat shortDate = DateFormat('d MMM yyyy', 'ar');
  static final DateFormat monthLabel = DateFormat('MMMM yyyy', 'ar');
}
