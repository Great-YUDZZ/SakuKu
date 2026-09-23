import 'package:sqflite/sqflite.dart';
import '../../domain/models/debt_entity.dart';
import '../../domain/models/investment_entity.dart';
import '../datasources/app_database.dart';
import '../models/debt_model.dart';
import '../models/investment_model.dart';

class PortfolioSummary {
  final double totalInvested;
  final double totalCurrentValue;
  final double totalUnrealizedPnL;
  final double returnPercentage;
  final double totalActiveDebt;
  final double totalActiveReceivable;
  final double netWorth; // Total Aset Investasi - Total Hutang Berjalan
  final int dueSoonCount;
  final int overdueCount;
  final int activeDebtCount;
  final int investmentCount;

  const PortfolioSummary({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalUnrealizedPnL,
    required this.returnPercentage,
    required this.totalActiveDebt,
    required this.totalActiveReceivable,
    required this.netWorth,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.activeDebtCount,
    required this.investmentCount,
  });
}

class PortfolioRepository {
  final AppDatabase _dbProvider;

  PortfolioRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  // ==========================================
  // DEBTS & RECEIVABLES (HUTANG & PIUTANG)
  // ==========================================

  Future<List<DebtEntity>> getDebts({
    DebtType? type,
    DebtStatus? status,
  }) async {
    final db = await _dbProvider.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (type != null) {
      whereClauses.add('${DebtModel.colType} = ?');
      whereArgs.add(type.name);
    }

    if (status != null) {
      whereClauses.add('${DebtModel.colStatus} = ?');
      whereArgs.add(status.name);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final rows = await db.query(
      DebtModel.tableName,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${DebtModel.colDueDate} ASC',
    );

    return rows.map((r) => DebtModel.fromMap(r).entity).toList();
  }

  Future<int> insertDebt(DebtEntity debt) async {
    final db = await _dbProvider.database;
    final model = DebtModel.fromEntity(debt);
    return await db.insert(
      DebtModel.tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDebt(DebtEntity debt) async {
    if (debt.id == null) return 0;
    final db = await _dbProvider.database;
    final model = DebtModel.fromEntity(debt);
    return await db.update(
      DebtModel.tableName,
      model.toMap(),
      where: '${DebtModel.colId} = ?',
      whereArgs: [debt.id],
    );
  }

  Future<int> deleteDebt(int id) async {
    final db = await _dbProvider.database;
    return await db.delete(
      DebtModel.tableName,
      where: '${DebtModel.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Rekam pembayaran cicilan / pelunasan hutang
  Future<void> recordRepayment(int debtId, double paymentAmount) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      DebtModel.tableName,
      where: '${DebtModel.colId} = ?',
      whereArgs: [debtId],
      limit: 1,
    );

    if (rows.isEmpty) return;
    final existing = DebtModel.fromMap(rows.first).entity;
    final newRemaining = (existing.remainingAmount - paymentAmount).clamp(0.0, existing.amount);
    final newStatus = newRemaining <= 0 ? DebtStatus.paid : existing.status;

    final updated = existing.copyWith(
      remainingAmount: newRemaining,
      status: newStatus,
    );

    await updateDebt(updated);
  }

  // ==========================================
  // INVESTMENTS (SAHAM, REKSADANA, CRYPTO, DLL)
  // ==========================================

  Future<List<InvestmentEntity>> getInvestments({
    InvestmentCategory? category,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      InvestmentModel.tableName,
      where: category != null ? '${InvestmentModel.colCategory} = ?' : null,
      whereArgs: category != null ? [category.name] : null,
      orderBy: '${InvestmentModel.colCurrentValue} DESC',
    );

    return rows.map((r) => InvestmentModel.fromMap(r).entity).toList();
  }

  Future<int> insertInvestment(InvestmentEntity investment) async {
    final db = await _dbProvider.database;
    final model = InvestmentModel.fromEntity(investment);
    return await db.insert(
      InvestmentModel.tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateInvestment(InvestmentEntity investment) async {
    if (investment.id == null) return 0;
    final db = await _dbProvider.database;
    final model = InvestmentModel.fromEntity(investment);
    return await db.update(
      InvestmentModel.tableName,
      model.toMap(),
      where: '${InvestmentModel.colId} = ?',
      whereArgs: [investment.id],
    );
  }

  Future<int> deleteInvestment(int id) async {
    final db = await _dbProvider.database;
    return await db.delete(
      InvestmentModel.tableName,
      where: '${InvestmentModel.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInvestmentCurrentValue(int id, double newCurrentValue) async {
    final db = await _dbProvider.database;
    await db.update(
      InvestmentModel.tableName,
      {InvestmentModel.colCurrentValue: newCurrentValue},
      where: '${InvestmentModel.colId} = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // PORTFOLIO SUMMARY AGGREGATION
  // ==========================================

  Future<PortfolioSummary> getPortfolioSummary() async {
    final debts = await getDebts();
    final investments = await getInvestments();

    double totalInvested = 0.0;
    double totalCurrentValue = 0.0;

    for (final inv in investments) {
      totalInvested += inv.investedAmount;
      totalCurrentValue += inv.currentValue;
    }

    final totalUnrealizedPnL = totalCurrentValue - totalInvested;
    final returnPercentage =
        totalInvested > 0 ? (totalUnrealizedPnL / totalInvested) * 100.0 : 0.0;

    double totalActiveDebt = 0.0;
    double totalActiveReceivable = 0.0;
    int dueSoonCount = 0;
    int overdueCount = 0;
    int activeDebtCount = 0;

    for (final d in debts) {
      if (!d.isPaid) {
        if (d.type == DebtType.debt) {
          totalActiveDebt += d.remainingAmount;
          activeDebtCount++;
        } else {
          totalActiveReceivable += d.remainingAmount;
        }

        if (d.isOverdue) {
          overdueCount++;
        } else if (d.isDueSoon) {
          dueSoonCount++;
        }
      }
    }

    final netWorth = totalCurrentValue - totalActiveDebt;

    return PortfolioSummary(
      totalInvested: totalInvested,
      totalCurrentValue: totalCurrentValue,
      totalUnrealizedPnL: totalUnrealizedPnL,
      returnPercentage: returnPercentage,
      totalActiveDebt: totalActiveDebt,
      totalActiveReceivable: totalActiveReceivable,
      netWorth: netWorth,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      activeDebtCount: activeDebtCount,
      investmentCount: investments.length,
    );
  }
}
