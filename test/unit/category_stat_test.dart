import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/data/repositories/transaction_repository.dart';
import 'package:local_financial_manager/domain/models/transaction_entity.dart';

void main() {
  group('CategoryStat & MonthlySummary Statistics Table', () {
    test('Kalkulasi CategoryStat menghitung persentase dan rata-rata dengan benar', () {
      const stat = CategoryStat(
        category: TransactionCategory.salary,
        type: TransactionType.income,
        totalAmount: 6000000.0,
        count: 2,
        percentage: 75.0,
        averageAmount: 3000000.0,
      );

      expect(stat.category, equals(TransactionCategory.salary));
      expect(stat.type, equals(TransactionType.income));
      expect(stat.totalAmount, equals(6000000.0));
      expect(stat.count, equals(2));
      expect(stat.percentage, equals(75.0));
      expect(stat.averageAmount, equals(3000000.0));
    });

    test('MonthlySummary menyimpan data statistik lengkap pemasukan dan pengeluaran', () {
      const summary = MonthlySummary(
        totalIncome: 10000000.0,
        totalExpense: 6000000.0,
        balance: 4000000.0,
        totalIncomeCount: 3,
        totalExpenseCount: 12,
        maxIncome: 7000000.0,
        maxExpense: 1500000.0,
        incomeStats: [
          CategoryStat(
            category: TransactionCategory.salary,
            type: TransactionType.income,
            totalAmount: 7000000.0,
            count: 1,
            percentage: 70.0,
            averageAmount: 7000000.0,
          ),
          CategoryStat(
            category: TransactionCategory.business,
            type: TransactionType.income,
            totalAmount: 3000000.0,
            count: 2,
            percentage: 30.0,
            averageAmount: 1500000.0,
          ),
        ],
        expenseStats: [
          CategoryStat(
            category: TransactionCategory.food,
            type: TransactionType.expense,
            totalAmount: 3000000.0,
            count: 8,
            percentage: 50.0,
            averageAmount: 375000.0,
          ),
        ],
        expenseByCategory: {
          TransactionCategory.food: 3000000.0,
        },
        incomeByCategory: {
          TransactionCategory.salary: 7000000.0,
          TransactionCategory.business: 3000000.0,
        },
      );

      expect(summary.totalIncome, equals(10000000.0));
      expect(summary.totalExpense, equals(6000000.0));
      expect(summary.balance, equals(4000000.0));
      expect(summary.totalIncomeCount, equals(3));
      expect(summary.totalExpenseCount, equals(12));
      expect(summary.maxIncome, equals(7000000.0));
      expect(summary.maxExpense, equals(1500000.0));
      expect(summary.incomeStats.length, equals(2));
      expect(summary.expenseStats.length, equals(1));
      expect(summary.incomeByCategory[TransactionCategory.salary], equals(7000000.0));
    });
  });
}
