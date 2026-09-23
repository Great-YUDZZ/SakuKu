import '../models/financial_health_ratio.dart';
import '../../core/utils/currency_formatter.dart';

class FinancialAnalysisService {
  const FinancialAnalysisService();

  FinancialHealthRatio analyze({
    required double totalIncome,
    required double totalExpense,
  }) {
    final netSavings = totalIncome - totalExpense;

    // Edge Case 1: Tidak ada pemasukan sama sekali
    if (totalIncome <= 0.0) {
      if (totalExpense > 0.0) {
        return FinancialHealthRatio(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          netSavings: netSavings,
          savingsRatio: -100.0,
          expenseToIncomeRatio: null,
          status: HealthStatus.fullDeficit,
          statusDescription: 'Defisit Penuh',
          recommendation:
              'Pengeluaran ${CurrencyFormatter.format(totalExpense)} tercatat tanpa adanya pemasukan bulan ini.',
        );
      } else {
        return const FinancialHealthRatio(
          totalIncome: 0.0,
          totalExpense: 0.0,
          netSavings: 0.0,
          savingsRatio: null,
          expenseToIncomeRatio: null,
          status: HealthStatus.noIncomeYet,
          statusDescription: 'Pemasukan belum tercatat',
          recommendation:
              'Catat pemasukan awal Anda untuk mengaktifkan analisis rasio kesehatan ekonomi.',
        );
      }
    }

    // Normal calculation: totalIncome > 0
    final savingsRatio = (netSavings / totalIncome) * 100.0;
    final expenseToIncomeRatio = (totalExpense / totalIncome) * 100.0;

    HealthStatus status;
    String statusDescription;
    String recommendation;

    if (savingsRatio >= FinancialHealthRatio.targetSavingsRatio &&
        expenseToIncomeRatio <= FinancialHealthRatio.maxExpenseRatio) {
      status = HealthStatus.healthy;
      statusDescription =
          'Kondisi Keuangan Sehat (Tabungan ${savingsRatio.toStringAsFixed(1)}%)';
      recommendation =
          'Pertahankan alokasi tabungan di atas target minimal 20%. Arus kas Anda dalam batas sangat aman.';
    } else if (savingsRatio >= 10.0 && expenseToIncomeRatio <= 90.0) {
      status = HealthStatus.warning;
      statusDescription =
          'Rasio Tabungan Tipis (${savingsRatio.toStringAsFixed(1)}%)';
      recommendation =
          'Alokasi tabungan di bawah target ideal 20%. Evaluasi pos pengeluaran sekunder untuk meningkatkan tabungan.';
    } else if (savingsRatio >= 0.0) {
      status = HealthStatus.critical;
      statusDescription =
          'Zona Bahaya Tabungan (< 10%)';
      recommendation =
          'Pengeluaran mendekati 100% pemasukan (${expenseToIncomeRatio.toStringAsFixed(1)}%). Segera rem pengeluaran non-esensial.';
    } else {
      status = HealthStatus.critical;
      statusDescription =
          'Defisit Anggaran (${savingsRatio.toStringAsFixed(1)}%)';
      recommendation =
          'Pengeluaran melebihi pemasukan bulan ini sebesar ${CurrencyFormatter.format(totalExpense - totalIncome)}. Prioritaskan pemotongan anggaran.';
    }

    return FinancialHealthRatio(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRatio: savingsRatio,
      expenseToIncomeRatio: expenseToIncomeRatio,
      status: status,
      statusDescription: statusDescription,
      recommendation: recommendation,
    );
  }
}
