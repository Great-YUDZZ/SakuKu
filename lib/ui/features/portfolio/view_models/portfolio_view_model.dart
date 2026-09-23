import 'package:flutter/foundation.dart';
import '../../../../data/repositories/portfolio_repository.dart';
import '../../../../domain/models/debt_entity.dart';
import '../../../../domain/models/investment_entity.dart';

export '../../../../data/repositories/portfolio_repository.dart' show PortfolioSummary;

class PortfolioViewModel extends ChangeNotifier {
  final PortfolioRepository _repository;

  PortfolioViewModel({PortfolioRepository? repository})
      : _repository = repository ?? PortfolioRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PortfolioSummary? _summary;
  PortfolioSummary? get summary => _summary;

  List<DebtEntity> _debts = [];
  List<DebtEntity> get debts => _debts;

  List<InvestmentEntity> _investments = [];
  List<InvestmentEntity> get investments => _investments;

  int _currentTabIndex = 0; // 0: Investasi, 1: Hutang & Piutang, 2: Kalkulator
  int get currentTabIndex => _currentTabIndex;

  InvestmentCategory? _selectedCategory;
  InvestmentCategory? get selectedCategory => _selectedCategory;

  DebtType _selectedDebtType = DebtType.debt;
  DebtType get selectedDebtType => _selectedDebtType;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final summary = await _repository.getPortfolioSummary();
      final debts = await _repository.getDebts();
      final investments = await _repository.getInvestments();

      _summary = summary;
      _debts = debts;
      _investments = investments;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading portfolio data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void setInvestmentCategory(InvestmentCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDebtType(DebtType type) {
    _selectedDebtType = type;
    notifyListeners();
  }

  List<InvestmentEntity> get filteredInvestments {
    if (_selectedCategory == null) return _investments;
    return _investments.where((i) => i.category == _selectedCategory).toList();
  }

  List<DebtEntity> get filteredDebts {
    return _debts.where((d) => d.type == _selectedDebtType).toList();
  }

  Future<void> addDebt(DebtEntity debt) async {
    await _repository.insertDebt(debt);
    await loadData();
  }

  Future<void> updateDebt(DebtEntity debt) async {
    await _repository.updateDebt(debt);
    await loadData();
  }

  Future<void> deleteDebt(int id) async {
    await _repository.deleteDebt(id);
    await loadData();
  }

  Future<void> recordRepayment(int id, double amount) async {
    await _repository.recordRepayment(id, amount);
    await loadData();
  }

  Future<void> addInvestment(InvestmentEntity investment) async {
    await _repository.insertInvestment(investment);
    await loadData();
  }

  Future<void> updateInvestment(InvestmentEntity investment) async {
    await _repository.updateInvestment(investment);
    await loadData();
  }

  Future<void> deleteInvestment(int id) async {
    await _repository.deleteInvestment(id);
    await loadData();
  }

  Future<void> updateInvestmentCurrentValue(int id, double newPrice) async {
    await _repository.updateInvestmentCurrentValue(id, newPrice);
    await loadData();
  }
}
