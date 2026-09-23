import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoanCalculationResult {
  final double principal;
  final double annualInterestRate;
  final int tenorMonths;
  final double monthlyInstallment;
  final double monthlyPrincipal;
  final double monthlyInterest;
  final double totalInterest;
  final double totalPayment;

  const LoanCalculationResult({
    required this.principal,
    required this.annualInterestRate,
    required this.tenorMonths,
    required this.monthlyInstallment,
    required this.monthlyPrincipal,
    required this.monthlyInterest,
    required this.totalInterest,
    required this.totalPayment,
  });
}

class CompoundGrowthYearlyPoint {
  final int year;
  final double totalInvested;
  final double totalEarnings;
  final double balance;

  const CompoundGrowthYearlyPoint({
    required this.year,
    required this.totalInvested,
    required this.totalEarnings,
    required this.balance,
  });
}

class CompoundGrowthResult {
  final double initialDeposit;
  final double monthlyContribution;
  final double annualReturnRate;
  final int years;
  final double totalInvested;
  final double totalEarnings;
  final double futureValue;
  final List<CompoundGrowthYearlyPoint> yearlyPoints;

  const CompoundGrowthResult({
    required this.initialDeposit,
    required this.monthlyContribution,
    required this.annualReturnRate,
    required this.years,
    required this.totalInvested,
    required this.totalEarnings,
    required this.futureValue,
    required this.yearlyPoints,
  });
}

enum DueUrgency {
  paid('Lunas', Color(0xFF059669), Icons.check_circle_rounded),
  safe('Jadwal Aman', Color(0xFF2563EB), Icons.schedule_rounded),
  warning('Segera (≤ 30 Hari)', Color(0xFFD97706), Icons.alarm_rounded),
  critical('Kritis (≤ 7 Hari)', Color(0xFFEA580C), Icons.warning_amber_rounded),
  overdue('Lewat Jatuh Tempo', Color(0xFFDC2626), Icons.error_rounded);

  final String label;
  final Color color;
  final IconData icon;

  const DueUrgency(this.label, this.color, this.icon);
}

class FinancialCalculatorService {
  const FinancialCalculatorService();

  /// Menghitung pinjaman dengan metode bunga flat (tetap)
  LoanCalculationResult calculateFlatLoan({
    required double principal,
    required double annualInterestRate,
    required int tenorMonths,
  }) {
    if (tenorMonths <= 0 || principal <= 0) {
      return LoanCalculationResult(
        principal: principal,
        annualInterestRate: annualInterestRate,
        tenorMonths: tenorMonths,
        monthlyInstallment: 0,
        monthlyPrincipal: 0,
        monthlyInterest: 0,
        totalInterest: 0,
        totalPayment: 0,
      );
    }

    final double rate = (annualInterestRate / 100.0);
    final double years = tenorMonths / 12.0;
    final double totalInterest = principal * rate * years;
    final double totalPayment = principal + totalInterest;
    final double monthlyInstallment = totalPayment / tenorMonths;
    final double monthlyPrincipal = principal / tenorMonths;
    final double monthlyInterest = totalInterest / tenorMonths;

    return LoanCalculationResult(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenorMonths: tenorMonths,
      monthlyInstallment: monthlyInstallment,
      monthlyPrincipal: monthlyPrincipal,
      monthlyInterest: monthlyInterest,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
    );
  }

  /// Menghitung pinjaman dengan metode bunga efektif / anuitas
  LoanCalculationResult calculateEffectiveAnnuity({
    required double principal,
    required double annualInterestRate,
    required int tenorMonths,
  }) {
    if (tenorMonths <= 0 || principal <= 0) {
      return calculateFlatLoan(
        principal: principal,
        annualInterestRate: annualInterestRate,
        tenorMonths: tenorMonths,
      );
    }

    if (annualInterestRate <= 0) {
      final monthly = principal / tenorMonths;
      return LoanCalculationResult(
        principal: principal,
        annualInterestRate: 0,
        tenorMonths: tenorMonths,
        monthlyInstallment: monthly,
        monthlyPrincipal: monthly,
        monthlyInterest: 0,
        totalInterest: 0,
        totalPayment: principal,
      );
    }

    final double monthlyRate = (annualInterestRate / 100.0) / 12.0;
    final double factor = math.pow(1 + monthlyRate, tenorMonths).toDouble();
    final double monthlyInstallment = principal * ((monthlyRate * factor) / (factor - 1));
    final double totalPayment = monthlyInstallment * tenorMonths;
    final double totalInterest = totalPayment - principal;

    return LoanCalculationResult(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenorMonths: tenorMonths,
      monthlyInstallment: monthlyInstallment,
      monthlyPrincipal: principal / tenorMonths,
      monthlyInterest: totalInterest / tenorMonths,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
    );
  }

  /// Menghitung proyeksi investasi bunga majemuk (Compound Interest) dengan DCA rutin
  CompoundGrowthResult calculateCompoundGrowth({
    required double initialDeposit,
    required double monthlyContribution,
    required double annualReturnRate,
    required int years,
  }) {
    final effectiveYears = math.max(1, years);
    final monthlyRate = (annualReturnRate / 100.0) / 12.0;
    final totalMonths = effectiveYears * 12;

    double currentBalance = initialDeposit;
    double currentInvested = initialDeposit;
    final List<CompoundGrowthYearlyPoint> yearlyPoints = [];

    for (int m = 1; m <= totalMonths; m++) {
      // Compound previous balance
      currentBalance = currentBalance * (1 + monthlyRate);
      // Add monthly contribution
      currentBalance += monthlyContribution;
      currentInvested += monthlyContribution;

      if (m % 12 == 0) {
        final year = m ~/ 12;
        final earnings = math.max(0.0, currentBalance - currentInvested);
        yearlyPoints.add(
          CompoundGrowthYearlyPoint(
            year: year,
            totalInvested: currentInvested,
            totalEarnings: earnings,
            balance: currentBalance,
          ),
        );
      }
    }

    final totalEarnings = math.max(0.0, currentBalance - currentInvested);

    return CompoundGrowthResult(
      initialDeposit: initialDeposit,
      monthlyContribution: monthlyContribution,
      annualReturnRate: annualReturnRate,
      years: effectiveYears,
      totalInvested: currentInvested,
      totalEarnings: totalEarnings,
      futureValue: currentBalance,
      yearlyPoints: yearlyPoints,
    );
  }

  /// Menghitung status urgensi tenggat waktu jatuh tempo
  DueUrgency calculateDueUrgency({
    required int daysRemaining,
    required bool isPaid,
  }) {
    if (isPaid) return DueUrgency.paid;
    if (daysRemaining < 0) return DueUrgency.overdue;
    if (daysRemaining <= 7) return DueUrgency.critical;
    if (daysRemaining <= 30) return DueUrgency.warning;
    return DueUrgency.safe;
  }
}
