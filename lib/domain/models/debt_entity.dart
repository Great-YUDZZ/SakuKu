import 'package:flutter/material.dart';

enum DebtType {
  debt('Hutang Saya', Icons.arrow_circle_down_rounded, Color(0xFFDC2626)),
  receivable('Piutang', Icons.arrow_circle_up_rounded, Color(0xFF059669));

  final String label;
  final IconData icon;
  final Color color;

  const DebtType(this.label, this.icon, this.color);

  static DebtType fromKey(String? key) {
    if (key == null) return DebtType.debt;
    return DebtType.values.firstWhere(
      (e) => e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => DebtType.debt,
    );
  }
}

enum InterestType {
  flat('Bunga Flat (Tetap)'),
  effective('Bunga Efektif / Anuitas'),
  none('Tanpa Bunga (0%)');

  final String label;
  const InterestType(this.label);

  static InterestType fromKey(String? key) {
    if (key == null) return InterestType.none;
    return InterestType.values.firstWhere(
      (e) => e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => InterestType.none,
    );
  }
}

enum DebtStatus {
  active('Aktif', Color(0xFF2563EB)),
  paid('Lunas', Color(0xFF059669)),
  overdue('Jatuh Tempo', Color(0xFFDC2626));

  final String label;
  final Color color;
  const DebtStatus(this.label, this.color);

  static DebtStatus fromKey(String? key) {
    if (key == null) return DebtStatus.active;
    return DebtStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => DebtStatus.active,
    );
  }
}

class DebtEntity {
  final int? id;
  final String title;
  final DebtType type;
  final String personOrInstitution;
  final double amount;
  final double remainingAmount;
  final double interestRate; // Suku bunga per tahun (%)
  final InterestType interestType;
  final DateTime startDate;
  final DateTime dueDate;
  final DebtStatus status;
  final String? notes;
  final DateTime createdAt;

  const DebtEntity({
    this.id,
    required this.title,
    required this.type,
    required this.personOrInstitution,
    required this.amount,
    required this.remainingAmount,
    this.interestRate = 0.0,
    this.interestType = InterestType.none,
    required this.startDate,
    required this.dueDate,
    this.status = DebtStatus.active,
    this.notes,
    required this.createdAt,
  });

  double get paidAmount => (amount - remainingAmount).clamp(0.0, amount);
  double get paidPercentage => amount > 0 ? (paidAmount / amount) * 100.0 : 100.0;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isPaid => status == DebtStatus.paid || remainingAmount <= 0;
  bool get isOverdue => !isPaid && (daysRemaining < 0 || status == DebtStatus.overdue);
  bool get isDueSoon => !isPaid && !isOverdue && daysRemaining <= 7;

  /// Estimasi bunga per bulan (flat)
  double get estimatedMonthlyInterest {
    if (interestRate <= 0) return 0.0;
    return (amount * (interestRate / 100.0)) / 12.0;
  }

  DebtEntity copyWith({
    int? id,
    String? title,
    DebtType? type,
    String? personOrInstitution,
    double? amount,
    double? remainingAmount,
    double? interestRate,
    InterestType? interestType,
    DateTime? startDate,
    DateTime? dueDate,
    DebtStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      personOrInstitution: personOrInstitution ?? this.personOrInstitution,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interestRate: interestRate ?? this.interestRate,
      interestType: interestType ?? this.interestType,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
