import 'package:flutter/foundation.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/financial_health_ratio.dart';
import '../../../../domain/models/transaction_entity.dart';
import '../../../../domain/services/financial_analysis_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final FinancialAnalysisService _analysisService;

  DashboardViewModel({
    TransactionRepository? transactionRepository,
    FinancialAnalysisService? analysisService,
  })  : _transactionRepository =
            transactionRepository ?? TransactionRepository(),
        _analysisService =
            analysisService ?? const FinancialAnalysisService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  MonthlySummary? _summary;
  MonthlySummary? get summary => _summary;

  FinancialHealthRatio? _healthRatio;
  FinancialHealthRatio? get healthRatio => _healthRatio;

  List<TransactionEntity> _recentTransactions = [];
  List<TransactionEntity> get recentTransactions => _recentTransactions;

  double _totalLifetimeBalance = 0.0;
  double get totalLifetimeBalance => _totalLifetimeBalance;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final summary =
          await _transactionRepository.getMonthlySummary(_selectedMonth);
      final transactions =
          await _transactionRepository.getTransactionsByMonth(_selectedMonth);
      final lifetime =
          await _transactionRepository.getTotalLifetimeBalance();

      final ratio = _analysisService.analyze(
        totalIncome: summary.totalIncome,
        totalExpense: summary.totalExpense,
      );

      _summary = summary;
      _healthRatio = ratio;
      _recentTransactions = transactions.take(10).toList();
      _totalLifetimeBalance = lifetime;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeMonth(DateTime newMonth) async {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    await loadDashboard();
  }

  Future<void> nextMonth() async {
    await changeMonth(
      DateTime(_selectedMonth.year, _selectedMonth.month + 1),
    );
  }

  Future<void> previousMonth() async {
    await changeMonth(
      DateTime(_selectedMonth.year, _selectedMonth.month - 1),
    );
  }

  Future<void> deleteTransaction(int id) async {
    await _transactionRepository.deleteTransaction(id);
    await loadDashboard();
  }
}
