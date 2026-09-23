import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }
}

enum TransactionCategory {
  food('Makanan & Minuman', Icons.restaurant_rounded, Color(0xFFF97316)),
  transport('Transportasi', Icons.directions_car_rounded, Color(0xFF0EA5E9)),
  bills('Tagihan & Utilitas', Icons.receipt_long_rounded, Color(0xFF8B5CF6)),
  shopping('Belanja', Icons.shopping_bag_rounded, Color(0xFFEC4899)),
  entertainment('Hiburan', Icons.sports_esports_rounded, Color(0xFFA855F7)),
  salary('Gaji & Upah', Icons.account_balance_wallet_rounded, Color(0xFF10B981)),
  business('Bisnis / Usaha', Icons.storefront_rounded, Color(0xFF06B6D4)),
  investment('Investasi', Icons.trending_up_rounded, Color(0xFF3B82F6)),
  health('Kesehatan', Icons.medical_services_rounded, Color(0xFFEF4444)),
  education('Pendidikan', Icons.school_rounded, Color(0xFF14B8A6)),
  other('Lain-lain', Icons.category_rounded, Color(0xFF64748B));

  final String label;
  final IconData icon;
  final Color color;

  const TransactionCategory(this.label, this.icon, this.color);

  static TransactionCategory fromKey(String? key) {
    if (key == null) return TransactionCategory.other;
    return TransactionCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == key.toLowerCase(),
      orElse: () => TransactionCategory.other,
    );
  }
}

class TransactionEntity {
  final int? id;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  TransactionEntity copyWith({
    int? id,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
