import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/data/repositories/transaction_repository.dart';

void main() {
  group('CashFlow Chart Models & Granularity Tests', () {
    test('TimePointCashFlow menyimpan data titik waktu dengan benar', () {
      final now = DateTime(2026, 9, 21);
      final point = TimePointCashFlow(
        label: '21 Sep',
        fullPeriodLabel: '21 September 2026',
        dateTime: now,
        income: 5000000.0,
        expense: 1500000.0,
        netBalance: 3500000.0,
        incomeCount: 2,
        expenseCount: 4,
      );

      expect(point.label, equals('21 Sep'));
      expect(point.fullPeriodLabel, equals('21 September 2026'));
      expect(point.income, equals(5000000.0));
      expect(point.expense, equals(1500000.0));
      expect(point.netBalance, equals(3500000.0));
      expect(point.incomeCount, equals(2));
      expect(point.expenseCount, equals(4));
    });

    test('TimeGranularity memiliki 3 opsi: daily, monthly, yearly', () {
      expect(TimeGranularity.values.length, equals(3));
      expect(TimeGranularity.values, contains(TimeGranularity.daily));
      expect(TimeGranularity.values, contains(TimeGranularity.monthly));
      expect(TimeGranularity.values, contains(TimeGranularity.yearly));
    });
  });
}
