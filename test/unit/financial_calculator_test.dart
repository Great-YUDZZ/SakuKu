import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/domain/services/financial_calculator_service.dart';

void main() {
  group('FinancialCalculatorService Tests', () {
    const service = FinancialCalculatorService();

    test('Bunga Flat: menghitung pokok, bunga, dan angsuran bulanan dengan tepat', () {
      // Pinjaman 12.000.000, Bunga 10% per tahun, Tenor 12 bulan (1 tahun)
      final result = service.calculateFlatLoan(
        principal: 12000000,
        annualInterestRate: 10,
        tenorMonths: 12,
      );

      // Total bunga = 12.000.000 * 10% * 1 thn = 1.200.000
      expect(result.totalInterest, equals(1200000));
      // Total bayar = 13.200.000
      expect(result.totalPayment, equals(13200000));
      // Cicilan per bulan = 13.200.000 / 12 = 1.100.000
      expect(result.monthlyInstallment, equals(1100000));
      expect(result.monthlyPrincipal, equals(1000000));
      expect(result.monthlyInterest, equals(100000));
    });

    test('Bunga Anuitas: menghitung cicilan bulanan efektif dengan rumus anuitas', () {
      // Pinjaman 100.000.000, Bunga 12% per tahun (1% per bulan), Tenor 12 bulan
      final result = service.calculateEffectiveAnnuity(
        principal: 100000000,
        annualInterestRate: 12,
        tenorMonths: 12,
      );

      // Rumus anuitas: 100.000.000 * (0.01 * (1.01)^12) / ((1.01)^12 - 1)
      // cicilan bulanan ~ 8.884.878
      expect(result.monthlyInstallment, greaterThan(8800000));
      expect(result.monthlyInstallment, lessThan(8900000));
      expect(result.totalPayment, greaterThan(100000000));
      expect(result.totalInterest, greaterThan(0));
    });

    test('Bunga Majemuk (Compound Interest DCA): proyeksi nilai masa depan investasi', () {
      // Modal awal 10.000.000, Nabung rutin 1.000.000 / bln, Return 12% / thn, 2 tahun
      final result = service.calculateCompoundGrowth(
        initialDeposit: 10000000,
        monthlyContribution: 1000000,
        annualReturnRate: 12,
        years: 2,
      );

      // Total modal = 10jt + 24 * 1jt = 34.000.000
      expect(result.totalInvested, equals(34000000));
      // Dengan return 12% majemuk, nilai akhir harus lebih tinggi dari modal
      expect(result.futureValue, greaterThan(34000000));
      expect(result.totalEarnings, greaterThan(0));
      expect(result.yearlyPoints.length, equals(2));
      expect(result.yearlyPoints[0].year, equals(1));
      expect(result.yearlyPoints[1].year, equals(2));
    });

    test('DueUrgency: mengevaluasi tingkat urgensi jatuh tempo pinjaman', () {
      // Kasus Lunas
      expect(service.calculateDueUrgency(daysRemaining: 10, isPaid: true), equals(DueUrgency.paid));

      // Kasus Lewat Jatuh Tempo (Overdue)
      expect(service.calculateDueUrgency(daysRemaining: -1, isPaid: false), equals(DueUrgency.overdue));

      // Kasus Kritis (<= 7 hari)
      expect(service.calculateDueUrgency(daysRemaining: 3, isPaid: false), equals(DueUrgency.critical));
      expect(service.calculateDueUrgency(daysRemaining: 7, isPaid: false), equals(DueUrgency.critical));

      // Kasus Peringatan (8 - 30 hari)
      expect(service.calculateDueUrgency(daysRemaining: 15, isPaid: false), equals(DueUrgency.warning));
      expect(service.calculateDueUrgency(daysRemaining: 30, isPaid: false), equals(DueUrgency.warning));

      // Kasus Aman (> 30 hari)
      expect(service.calculateDueUrgency(daysRemaining: 45, isPaid: false), equals(DueUrgency.safe));
    });
  });
}
