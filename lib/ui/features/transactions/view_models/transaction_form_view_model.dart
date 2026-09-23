import 'package:flutter/foundation.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/transaction_entity.dart';

class TransactionFormViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionFormViewModel({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  TransactionType _type = TransactionType.expense;
  TransactionType get type => _type;

  double _amount = 0.0;
  double get amount => _amount;
  String _amountRawText = '';
  String get amountRawText => _amountRawText;

  TransactionCategory? _category = TransactionCategory.food;
  TransactionCategory? get category => _category;

  DateTime _date = DateTime.now();
  DateTime get date => _date;

  String _description = '';
  String get description => _description;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isValid =>
      _amount > 0.0 &&
      _category != null &&
      _description.trim().isNotEmpty &&
      !_isSaving;

  void setType(TransactionType newType) {
    _type = newType;
    if (_type == TransactionType.income && _category == TransactionCategory.food) {
      _category = TransactionCategory.salary;
    } else if (_type == TransactionType.expense &&
        _category == TransactionCategory.salary) {
      _category = TransactionCategory.food;
    }
    notifyListeners();
  }

  void setAmountFromInput(String raw) {
    _amountRawText = raw;
    _amount = CurrencyFormatter.parse(raw);
    _errorMessage = null;
    notifyListeners();
  }

  void setCategory(TransactionCategory newCategory) {
    _category = newCategory;
    notifyListeners();
  }

  void setDate(DateTime newDate) {
    _date = newDate;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> saveTransaction() async {
    if (!isValid) {
      if (_amount <= 0.0) {
        _errorMessage = 'Nominal harus lebih besar dari 0.';
      } else if (_description.trim().isEmpty) {
        _errorMessage = 'Deskripsi tujuan transaksi tidak boleh kosong.';
      } else if (_category == null) {
        _errorMessage = 'Pilih salah satu kategori transaksi.';
      }
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTransaction = TransactionEntity(
        description: _description.trim(),
        amount: _amount,
        type: _type,
        category: _category!,
        date: _date,
        createdAt: DateTime.now(),
      );

      await _repository.insertTransaction(newTransaction);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan transaksi: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
