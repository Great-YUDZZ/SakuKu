import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/data/repositories/transaction_repository.dart';
import 'package:local_financial_manager/domain/models/transaction_entity.dart';

void main() {
  group('CategoryPieChart Calculations & Logic', () {
    test('Kalkulasi sudut busur (sweep angle) untuk diagram lingkaran', () {
      const stats = [
        CategoryStat(
          category: TransactionCategory.food,
          type: TransactionType.expense,
          totalAmount: 500000.0,
          count: 5,
          percentage: 50.0,
          averageAmount: 100000.0,
        ),
        CategoryStat(
          category: TransactionCategory.transport,
          type: TransactionType.expense,
          totalAmount: 300000.0,
          count: 3,
          percentage: 30.0,
          averageAmount: 100000.0,
        ),
        CategoryStat(
          category: TransactionCategory.bills,
          type: TransactionType.expense,
          totalAmount: 200000.0,
          count: 1,
          percentage: 20.0,
          averageAmount: 200000.0,
        ),
      ];

      double totalSweep = 0.0;
      for (final s in stats) {
        final sweep = (s.percentage / 100.0) * (2 * math.pi);
        totalSweep += sweep;
      }

      // Total sweep angle harus tepat 2 * pi (360 derajat)
      expect(totalSweep, closeTo(2 * math.pi, 0.0001));
    });

    test('Algoritma normalisasi sudut dan deteksi irisan pada polar coordinate', () {
      // Misal 3 kategori: A (50%), B (30%), C (20%)
      const percentages = [50.0, 30.0, 20.0];
      final sweeps = percentages.map((p) => (p / 100.0) * (2 * math.pi)).toList();

      int findSegment(double normalizedAngle) {
        double current = 0.0;
        for (int i = 0; i < sweeps.length; i++) {
          if (normalizedAngle >= current && normalizedAngle < current + sweeps[i]) {
            return i;
          }
          current += sweeps[i];
        }
        return 0;
      }

      // Sudut di awal (0.1 rad) harus jatuh di kategori 0 (50% = 3.14 rad)
      expect(findSegment(0.1), equals(0));
      // Sudut 3.0 rad masih kategori 0
      expect(findSegment(3.0), equals(0));
      // Sudut 3.5 rad jatuh di kategori 1 (3.1415 + 1.884 = 5.02 rad)
      expect(findSegment(3.5), equals(1));
      // Sudut 5.5 rad jatuh di kategori 2 (sampai 6.28 rad)
      expect(findSegment(5.5), equals(2));
    });
  });
}
