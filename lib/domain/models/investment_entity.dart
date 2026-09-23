import 'package:flutter/material.dart';

enum InvestmentCategory {
  stocks('Saham', Icons.trending_up_rounded, Color(0xFF2563EB)),
  mutualFund('Reksadana', Icons.pie_chart_rounded, Color(0xFF0284C7)),
  crypto('Crypto / Aset Kripto', Icons.currency_bitcoin_rounded, Color(0xFF7C3AED)),
  bonds('SBN & Obligasi', Icons.assured_workload_rounded, Color(0xFF4F46E5)),
  gold('Emas & Logam Mulia', Icons.monetization_on_rounded, Color(0xFFD97706)),
  deposit('Deposito Berjangka', Icons.account_balance_rounded, Color(0xFF059669)),
  other('Lain-lain', Icons.widgets_rounded, Color(0xFF64748B));

  final String label;
  final IconData icon;
  final Color color;

  const InvestmentCategory(this.label, this.icon, this.color);

  static InvestmentCategory fromKey(String? key) {
    if (key == null) return InvestmentCategory.other;
    return InvestmentCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => InvestmentCategory.other,
    );
  }
}

class InvestmentEntity {
  final int? id;
  final String name;
  final InvestmentCategory category;
  final String platform; // e.g. Bibit, Ajaib, Indodax, Bareksa, Bank BCA
  final double investedAmount; // Modal pokok awal yang disetor
  final double currentValue; // Nilai pasar / portofolio terkini
  final double? targetAmount; // Target capaian nilai
  final double expectedReturnRate; // Ekspektasi imbal hasil tahunan (%)
  final DateTime startDate;
  final DateTime? maturityDate; // Tenggat waktu horizon / jatuh tempo (jika ada)
  final String? notes;
  final DateTime createdAt;

  const InvestmentEntity({
    this.id,
    required this.name,
    required this.category,
    required this.platform,
    required this.investedAmount,
    required this.currentValue,
    this.targetAmount,
    this.expectedReturnRate = 0.0,
    required this.startDate,
    this.maturityDate,
    this.notes,
    required this.createdAt,
  });

  /// Keuntungan/kerugian nominal belum terealisasi (Unrealized PnL)
  double get profitOrLoss => currentValue - investedAmount;

  /// Persentase imbal hasil return (ROI)
  double get returnPercentage =>
      investedAmount > 0 ? (profitOrLoss / investedAmount) * 100.0 : 0.0;

  bool get isProfitable => profitOrLoss >= 0;

  /// Sisa hari menuju jatuh tempo / target horizon (jika diatur)
  int? get daysToMaturity {
    if (maturityDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mature = DateTime(maturityDate!.year, maturityDate!.month, maturityDate!.day);
    return mature.difference(today).inDays;
  }

  InvestmentEntity copyWith({
    int? id,
    String? name,
    InvestmentCategory? category,
    String? platform,
    double? investedAmount,
    double? currentValue,
    double? targetAmount,
    double? expectedReturnRate,
    DateTime? startDate,
    DateTime? maturityDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return InvestmentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      platform: platform ?? this.platform,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      targetAmount: targetAmount ?? this.targetAmount,
      expectedReturnRate: expectedReturnRate ?? this.expectedReturnRate,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
