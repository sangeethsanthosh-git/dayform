import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryItem {
  final String id;
  final String name;
  final Color color;
  final Color foregroundColor;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.color,
    required this.foregroundColor,
    required this.icon,
  });
}

class CategoryDefinitions {
  static const CategoryItem work = CategoryItem(
    id: 'work',
    name: 'Work',
    color: AppColors.teal,
    foregroundColor: AppColors.tealForeground,
    icon: Icons.work_outline_rounded,
  );

  static CategoryItem get personal => CategoryItem(
    id: 'personal',
    name: 'Personal',
    color: AppColors.warmAmber,
    foregroundColor: AppColors.warmAmberForeground,
    icon: Icons.person_outline_rounded,
  );

  static const CategoryItem study = CategoryItem(
    id: 'study',
    name: 'Study',
    color: AppColors.lavender,
    foregroundColor: AppColors.lavenderForeground,
    icon: Icons.menu_book_rounded,
  );

  static const CategoryItem health = CategoryItem(
    id: 'health',
    name: 'Health',
    color: AppColors.sage,
    foregroundColor: AppColors.sageForeground,
    icon: Icons.favorite_outline_rounded,
  );

  static const CategoryItem finance = CategoryItem(
    id: 'finance',
    name: 'Finance',
    color: AppColors.dustyRose,
    foregroundColor: AppColors.dustyRoseForeground,
    icon: Icons.account_balance_wallet_outlined,
  );

  static const CategoryItem social = CategoryItem(
    id: 'social',
    name: 'Social',
    color: AppColors.lavender,
    foregroundColor: AppColors.lavenderForeground,
    icon: Icons.celebration_outlined,
  );

  static List<CategoryItem> get all => [
    work,
    personal,
    study,
    health,
    finance,
    social,
  ];

  static CategoryItem getById(String? id) {
    if (id == null) return personal;
    return all.firstWhere(
      (cat) => cat.id.toLowerCase() == id.toLowerCase(),
      orElse: () => personal,
    );
  }
}
