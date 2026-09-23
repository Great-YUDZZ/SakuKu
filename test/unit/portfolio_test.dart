import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/domain/models/debt_entity.dart';
import 'package:local_financial_manager/domain/models/investment_entity.dart';

void main() {
  group('DebtEntity & InvestmentEntity Tests', () {
    test('DebtEntity: persentase pelunasan dan estimasi bunga bulanan', () {
      final debt = DebtEntity(
        id: 1,
        title: 'KPR Rumah',
        type: DebtType.debt,
        personOrInstitution: 'Bank Mandiri',
        amount: 300000000,
        remainingAmount: 150000000, // sudah lunas 50%
        interestRate: 6.0, // 6% per tahun
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        dueDate: DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.now(),
      );

      expect(debt.paidAmount, equals(150000000));
      expect(debt.paidPercentage, equals(50.0));
      expect(debt.isPaid, isFalse);
      expect(debt.daysRemaining, greaterThan(300));
      // Bunga bulanan = (300jt * 6%) / 12 = 1.500.000
      expect(debt.estimatedMonthlyInterest, equals(1500000));
    });

    test('InvestmentEntity: kalkulasi profit/loss nominal dan persentase ROI', () {
      // Kasus Profit
      final stockInv = InvestmentEntity(
        id: 1,
        name: 'BBCA',
        category: InvestmentCategory.stocks,
        platform: 'Ajaib',
        investedAmount: 10000000,
        currentValue: 12500000, // Profit 2.500.000 (+25%)
        startDate: DateTime.now().subtract(const Duration(days: 100)),
        createdAt: DateTime.now(),
      );

      expect(stockInv.profitOrLoss, equals(2500000));
      expect(stockInv.returnPercentage, equals(25.0));
      expect(stockInv.isProfitable, isTrue);

      // Kasus Loss
      final cryptoInv = InvestmentEntity(
        id: 2,
        name: 'Ethereum',
        category: InvestmentCategory.crypto,
        platform: 'Indodax',
        investedAmount: 10000000,
        currentValue: 8000000, // Rugi 2.000.000 (-20%)
        startDate: DateTime.now().subtract(const Duration(days: 50)),
        createdAt: DateTime.now(),
      );

      expect(cryptoInv.profitOrLoss, equals(-2000000));
      expect(cryptoInv.returnPercentage, equals(-20.0));
      expect(cryptoInv.isProfitable, isFalse);
    });
  });
}
