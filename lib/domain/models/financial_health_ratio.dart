import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum HealthStatus {
  healthy,
  warning,
  critical,
  fullDeficit,
  noIncomeYet;

  String get label {
    switch (this) {
      case HealthStatus.healthy:
        return 'Kondisi Sehat';
      case HealthStatus.warning:
        return 'Perlu Waspada';
      case HealthStatus.critical:
        return 'Zona Kritis';
      case HealthStatus.fullDeficit:
        return 'Defisit Penuh';
      case HealthStatus.noIncomeYet:
        return 'Pemasukan Belum Ada';
    }
  }

  Color get color {
    switch (this) {
      case HealthStatus.healthy:
        return AppColors.income;
      case HealthStatus.warning:
        return AppColors.warning;
      case HealthStatus.critical:
      case HealthStatus.fullDeficit:
        return AppColors.expense;
      case HealthStatus.noIncomeYet:
        return AppColors.textMuted;
    }
  }

  Color get glowColor {
    switch (this) {
      case HealthStatus.healthy:
        return AppColors.incomeGlow;
      case HealthStatus.warning:
        return AppColors.warningGlow;
      case HealthStatus.critical:
      case HealthStatus.fullDeficit:
        return AppColors.expenseGlow;
      case HealthStatus.noIncomeYet:
        return Colors.transparent;
    }
  }

  IconData get icon {
    switch (this) {
      case HealthStatus.healthy:
        return Icons.verified_rounded;
      case HealthStatus.warning:
        return Icons.warning_amber_rounded;
      case HealthStatus.critical:
      case HealthStatus.fullDeficit:
        return Icons.error_outline_rounded;
      case HealthStatus.noIncomeYet:
        return Icons.info_outline_rounded;
    }
  }
}

class FinancialHealthRatio {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double? savingsRatio; // %
  final double? expenseToIncomeRatio; // %
  final HealthStatus status;
  final String statusDescription;
  final String recommendation;

  const FinancialHealthRatio({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRatio,
    required this.expenseToIncomeRatio,
    required this.status,
    required this.statusDescription,
    required this.recommendation,
  });

  /// Target rasio tabungan minimal 20%
  static const double targetSavingsRatio = 20.0;

  /// Batas aman rasio pengeluaran maksimal 80%
  static const double maxExpenseRatio = 80.0;
}
