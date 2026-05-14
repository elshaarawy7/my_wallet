import 'package:flutter/material.dart';

class IconMapper {
  static final Map<String, IconData> icons = {
    'restaurant': Icons.restaurant_rounded,
    'coffee': Icons.local_cafe_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'sports_soccer': Icons.sports_soccer_rounded,
    'payments': Icons.payments_rounded,
    'celebration': Icons.celebration_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'medical': Icons.medical_services_rounded,
    'school': Icons.school_rounded,
    'home': Icons.home_rounded,
  };

  static IconData fromKey(String key) => icons[key] ?? Icons.category_rounded;
}
