import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/domain/models/financial_health_ratio.dart';
import 'package:local_financial_manager/domain/services/financial_analysis_service.dart';

void main() {
  group('FinancialAnalysisService (FR-02 & Edge Cases)', () {
    const service = FinancialAnalysisService();

    test('Harus mengidentifikasi status Sehat saat Savings Ratio >= 20%', () {
      // Pemasukan 10.000.000, Pengeluaran 7.000.000 -> Tabungan 3.000.000 (30%)
      final result = service.analyze(
        totalIncome: 10000000.0,
        totalExpense: 7000000.0,
      );

      expect(result.status, equals(HealthStatus.healthy));
      expect(result.savingsRatio, closeTo(30.0, 0.01));
      expect(result.expenseToIncomeRatio, closeTo(70.0, 0.01));
      expect(result.netSavings, equals(3000000.0));
    });

    test('Harus mengidentifikasi status Perlu Waspada saat Savings Ratio antara 10% - 19.9%', () {
      // Pemasukan 10.000.000, Pengeluaran 8.500.000 -> Tabungan 1.500.000 (15%)
      final result = service.analyze(
        totalIncome: 10000000.0,
        totalExpense: 8500000.0,
      );

      expect(result.status, equals(HealthStatus.warning));
      expect(result.savingsRatio, closeTo(15.0, 0.01));
      expect(result.expenseToIncomeRatio, closeTo(85.0, 0.01));
    });

    test('Harus mengidentifikasi status Zona Kritis saat Savings Ratio < 10%', () {
      // Pemasukan 10.000.000, Pengeluaran 9.500.000 -> Tabungan 500.000 (5%)
      final result = service.analyze(
        totalIncome: 10000000.0,
        totalExpense: 9500000.0,
      );

      expect(result.status, equals(HealthStatus.critical));
      expect(result.savingsRatio, closeTo(5.0, 0.01));
    });

    test('Edge Case: Pemasukan 0 dengan Pengeluaran > 0 wajib menghasilkan Defisit Penuh tanpa DivideByZero', () {
      final result = service.analyze(
        totalIncome: 0.0,
        totalExpense: 1500000.0,
      );

      expect(result.status, equals(HealthStatus.fullDeficit));
      expect(result.statusDescription, equals('Defisit Penuh'));
      expect(result.netSavings, equals(-1500000.0));
      expect(result.expenseToIncomeRatio, isNull);
    });

    test('Edge Case: Pemasukan 0 dan Pengeluaran 0 wajib menampilkan status Pemasukan Belum Tercatat', () {
      final result = service.analyze(
        totalIncome: 0.0,
        totalExpense: 0.0,
      );

      expect(result.status, equals(HealthStatus.noIncomeYet));
      expect(result.statusDescription, equals('Pemasukan belum tercatat'));
      expect(result.savingsRatio, isNull);
      expect(result.expenseToIncomeRatio, isNull);
    });
  });
}
