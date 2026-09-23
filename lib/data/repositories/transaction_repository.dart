import 'package:sqflite/sqflite.dart';
import '../../domain/models/transaction_entity.dart';
import '../datasources/app_database.dart';
import '../models/transaction_model.dart';

class CategoryStat {
  final TransactionCategory category;
  final TransactionType type;
  final double totalAmount;
  final int count;
  final double percentage;
  final double averageAmount;

  const CategoryStat({
    required this.category,
    required this.type,
    required this.totalAmount,
    required this.count,
    required this.percentage,
    required this.averageAmount,
  });
}

enum TimeGranularity {
  daily,
  monthly,
  yearly,
}

class TimePointCashFlow {
  final String label;
  final String fullPeriodLabel;
  final DateTime dateTime;
  final double income;
  final double expense;
  final double netBalance;
  final int incomeCount;
  final int expenseCount;

  const TimePointCashFlow({
    required this.label,
    required this.fullPeriodLabel,
    required this.dateTime,
    required this.income,
    required this.expense,
    required this.netBalance,
    this.incomeCount = 0,
    this.expenseCount = 0,
  });
}

class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int totalIncomeCount;
  final int totalExpenseCount;
  final double maxIncome;
  final double maxExpense;
  final List<CategoryStat> incomeStats;
  final List<CategoryStat> expenseStats;
  final Map<TransactionCategory, double> expenseByCategory;
  final Map<TransactionCategory, double> incomeByCategory;

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.totalIncomeCount = 0,
    this.totalExpenseCount = 0,
    this.maxIncome = 0.0,
    this.maxExpense = 0.0,
    this.incomeStats = const [],
    this.expenseStats = const [],
    required this.expenseByCategory,
    this.incomeByCategory = const {},
  });
}

class TransactionRepository {
  final AppDatabase _dbProvider;

  TransactionRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<int> insertTransaction(TransactionEntity transaction) async {
    final db = await _dbProvider.database;
    final map = TransactionModel.toMap(transaction);
    return await db.insert(
      TransactionModel.tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionEntity transaction) async {
    if (transaction.id == null) return 0;
    final db = await _dbProvider.database;
    final map = TransactionModel.toMap(transaction);
    return await db.update(
      TransactionModel.tableName,
      map,
      where: '${TransactionModel.colId} = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _dbProvider.database;
    return await db.delete(
      TransactionModel.tableName,
      where: '${TransactionModel.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionEntity>> getAllTransactions({
    TransactionType? type,
    String? searchQuery,
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await _dbProvider.database;

    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (type != null) {
      whereClauses.add('${TransactionModel.colType} = ?');
      whereArgs.add(type.name);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add(
        '(${TransactionModel.colDescription} LIKE ? OR ${TransactionModel.colCategory} LIKE ?)',
      );
      final query = '%${searchQuery.trim()}%';
      whereArgs.add(query);
      whereArgs.add(query);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      TransactionModel.tableName,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${TransactionModel.colDate} DESC, ${TransactionModel.colId} DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionEntity>> getTransactionsByMonth(DateTime monthYear) async {
    final db = await _dbProvider.database;

    final startOfMonth = DateTime(monthYear.year, monthYear.month, 1);
    final nextMonth = DateTime(monthYear.year, monthYear.month + 1, 1);

    final maps = await db.query(
      TransactionModel.tableName,
      where:
          '${TransactionModel.colDate} >= ? AND ${TransactionModel.colDate} < ?',
      whereArgs: [startOfMonth.toIso8601String(), nextMonth.toIso8601String()],
      orderBy: '${TransactionModel.colDate} DESC',
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<MonthlySummary> getMonthlySummary(DateTime monthYear) async {
    final db = await _dbProvider.database;

    final startOfMonth = DateTime(monthYear.year, monthYear.month, 1);
    final nextMonth = DateTime(monthYear.year, monthYear.month + 1, 1);

    // Kueri agregasi pendapatan vs pengeluaran
    final List<Map<String, dynamic>> summaryRows = await db.rawQuery('''
      SELECT 
        ${TransactionModel.colType}, 
        SUM(${TransactionModel.colAmount}) as total,
        COUNT(*) as count,
        MAX(${TransactionModel.colAmount}) as max_amount
      FROM ${TransactionModel.tableName}
      WHERE ${TransactionModel.colDate} >= ? AND ${TransactionModel.colDate} < ?
      GROUP BY ${TransactionModel.colType}
    ''', [startOfMonth.toIso8601String(), nextMonth.toIso8601String()]);

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    int totalIncomeCount = 0;
    int totalExpenseCount = 0;
    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (var row in summaryRows) {
      final type = row[TransactionModel.colType] as String?;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      final count = ((row['count'] as num?) ?? 0).toInt();
      final maxVal = ((row['max_amount'] as num?) ?? 0.0).toDouble();
      if (type == 'income') {
        totalIncome = total;
        totalIncomeCount = count;
        maxIncome = maxVal;
      } else if (type == 'expense') {
        totalExpense = total;
        totalExpenseCount = count;
        maxExpense = maxVal;
      }
    }

    // Kueri statistik komprehensif per kategori untuk pemasukan dan pengeluaran
    final List<Map<String, dynamic>> catStatRows = await db.rawQuery('''
      SELECT 
        ${TransactionModel.colType},
        ${TransactionModel.colCategory}, 
        SUM(${TransactionModel.colAmount}) as total,
        COUNT(*) as count
      FROM ${TransactionModel.tableName}
      WHERE ${TransactionModel.colDate} >= ? AND ${TransactionModel.colDate} < ?
      GROUP BY ${TransactionModel.colType}, ${TransactionModel.colCategory}
      ORDER BY total DESC
    ''', [startOfMonth.toIso8601String(), nextMonth.toIso8601String()]);

    final List<CategoryStat> incomeStats = [];
    final List<CategoryStat> expenseStats = [];
    final Map<TransactionCategory, double> expenseByCategory = {};
    final Map<TransactionCategory, double> incomeByCategory = {};

    for (var row in catStatRows) {
      final typeStr = row[TransactionModel.colType] as String?;
      final catKey = row[TransactionModel.colCategory] as String?;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      final count = ((row['count'] as num?) ?? 0).toInt();
      final cat = TransactionCategory.fromKey(catKey);
      final avg = count > 0 ? total / count : 0.0;

      if (typeStr == 'income') {
        final pct = totalIncome > 0 ? (total / totalIncome) * 100.0 : 0.0;
        incomeByCategory[cat] = total;
        incomeStats.add(CategoryStat(
          category: cat,
          type: TransactionType.income,
          totalAmount: total,
          count: count,
          percentage: pct,
          averageAmount: avg,
        ));
      } else if (typeStr == 'expense') {
        final pct = totalExpense > 0 ? (total / totalExpense) * 100.0 : 0.0;
        expenseByCategory[cat] = total;
        expenseStats.add(CategoryStat(
          category: cat,
          type: TransactionType.expense,
          totalAmount: total,
          count: count,
          percentage: pct,
          averageAmount: avg,
        ));
      }
    }

    return MonthlySummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      totalIncomeCount: totalIncomeCount,
      totalExpenseCount: totalExpenseCount,
      maxIncome: maxIncome,
      maxExpense: maxExpense,
      incomeStats: incomeStats,
      expenseStats: expenseStats,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
    );
  }

  Future<double> getTotalLifetimeBalance() async {
    final db = await _dbProvider.database;

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT 
        ${TransactionModel.colType}, 
        SUM(${TransactionModel.colAmount}) as total
      FROM ${TransactionModel.tableName}
      GROUP BY ${TransactionModel.colType}
    ''');

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var row in rows) {
      final type = row[TransactionModel.colType] as String?;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      if (type == 'income') {
        totalIncome = total;
      } else if (type == 'expense') {
        totalExpense = total;
      }
    }

    return totalIncome - totalExpense;
  }

  Future<List<TimePointCashFlow>> getDailyCashFlow(DateTime monthYear) async {
    final db = await _dbProvider.database;
    final year = monthYear.year;
    final month = monthYear.month;
    final startOfMonth = DateTime(year, month, 1);
    final nextMonth = DateTime(year, month + 1, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT 
        substr(${TransactionModel.colDate}, 1, 10) as day_key,
        ${TransactionModel.colType},
        SUM(${TransactionModel.colAmount}) as total,
        COUNT(*) as count
      FROM ${TransactionModel.tableName}
      WHERE ${TransactionModel.colDate} >= ? AND ${TransactionModel.colDate} < ?
      GROUP BY day_key, ${TransactionModel.colType}
    ''', [startOfMonth.toIso8601String(), nextMonth.toIso8601String()]);

    final Map<String, Map<String, dynamic>> grouped = {};
    for (var row in rows) {
      final key = row['day_key'] as String;
      final type = row[TransactionModel.colType] as String;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      final count = ((row['count'] as num?) ?? 0).toInt();

      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0});
      if (type == 'income') {
        grouped[key]!['income'] = total;
        grouped[key]!['incomeCount'] = count;
      } else if (type == 'expense') {
        grouped[key]!['expense'] = total;
        grouped[key]!['expenseCount'] = count;
      }
    }

    final List<TimePointCashFlow> points = [];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    for (int day = 1; day <= daysInMonth; day++) {
      final dayStr = day.toString().padLeft(2, '0');
      final monthStr = month.toString().padLeft(2, '0');
      final dayKey = '$year-$monthStr-$dayStr';
      final dt = DateTime(year, month, day);

      final data = grouped[dayKey] ?? {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0};
      final inc = data['income'] as double;
      final exp = data['expense'] as double;

      points.add(TimePointCashFlow(
        label: '$day ${monthNames[month - 1]}',
        fullPeriodLabel: '$day ${monthNames[month - 1]} $year',
        dateTime: dt,
        income: inc,
        expense: exp,
        netBalance: inc - exp,
        incomeCount: data['incomeCount'] as int,
        expenseCount: data['expenseCount'] as int,
      ));
    }

    return points;
  }

  Future<List<TimePointCashFlow>> getMonthlyCashFlow(int year) async {
    final db = await _dbProvider.database;
    final startOfYear = DateTime(year, 1, 1);
    final nextYear = DateTime(year + 1, 1, 1);

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT 
        substr(${TransactionModel.colDate}, 1, 7) as month_key,
        ${TransactionModel.colType},
        SUM(${TransactionModel.colAmount}) as total,
        COUNT(*) as count
      FROM ${TransactionModel.tableName}
      WHERE ${TransactionModel.colDate} >= ? AND ${TransactionModel.colDate} < ?
      GROUP BY month_key, ${TransactionModel.colType}
    ''', [startOfYear.toIso8601String(), nextYear.toIso8601String()]);

    final Map<String, Map<String, dynamic>> grouped = {};
    for (var row in rows) {
      final key = row['month_key'] as String;
      final type = row[TransactionModel.colType] as String;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      final count = ((row['count'] as num?) ?? 0).toInt();

      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0});
      if (type == 'income') {
        grouped[key]!['income'] = total;
        grouped[key]!['incomeCount'] = count;
      } else if (type == 'expense') {
        grouped[key]!['expense'] = total;
        grouped[key]!['expenseCount'] = count;
      }
    }

    final List<TimePointCashFlow> points = [];
    final monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final monthFull = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    for (int m = 1; m <= 12; m++) {
      final mStr = m.toString().padLeft(2, '0');
      final monthKey = '$year-$mStr';
      final dt = DateTime(year, m, 1);

      final data = grouped[monthKey] ?? {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0};
      final inc = data['income'] as double;
      final exp = data['expense'] as double;

      points.add(TimePointCashFlow(
        label: monthShort[m - 1],
        fullPeriodLabel: '${monthFull[m - 1]} $year',
        dateTime: dt,
        income: inc,
        expense: exp,
        netBalance: inc - exp,
        incomeCount: data['incomeCount'] as int,
        expenseCount: data['expenseCount'] as int,
      ));
    }

    return points;
  }

  Future<List<TimePointCashFlow>> getYearlyCashFlow() async {
    final db = await _dbProvider.database;

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT 
        substr(${TransactionModel.colDate}, 1, 4) as year_key,
        ${TransactionModel.colType},
        SUM(${TransactionModel.colAmount}) as total,
        COUNT(*) as count
      FROM ${TransactionModel.tableName}
      GROUP BY year_key, ${TransactionModel.colType}
      ORDER BY year_key ASC
    ''');

    final Map<String, Map<String, dynamic>> grouped = {};
    for (var row in rows) {
      final key = row['year_key'] as String;
      final type = row[TransactionModel.colType] as String;
      final total = ((row['total'] as num?) ?? 0.0).toDouble();
      final count = ((row['count'] as num?) ?? 0).toInt();

      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0});
      if (type == 'income') {
        grouped[key]!['income'] = total;
        grouped[key]!['incomeCount'] = count;
      } else if (type == 'expense') {
        grouped[key]!['expense'] = total;
        grouped[key]!['expenseCount'] = count;
      }
    }

    final currentYear = DateTime.now().year;
    final Set<int> allYears = {};
    for (var yKey in grouped.keys) {
      final parsed = int.tryParse(yKey);
      if (parsed != null) allYears.add(parsed);
    }
    for (int y = currentYear - 2; y <= currentYear; y++) {
      allYears.add(y);
    }
    final sortedYears = allYears.toList()..sort();

    final List<TimePointCashFlow> points = [];
    for (var y in sortedYears) {
      final yKey = y.toString();
      final dt = DateTime(y, 1, 1);

      final data = grouped[yKey] ?? {'income': 0.0, 'expense': 0.0, 'incomeCount': 0, 'expenseCount': 0};
      final inc = data['income'] as double;
      final exp = data['expense'] as double;

      points.add(TimePointCashFlow(
        label: yKey,
        fullPeriodLabel: 'Tahun $yKey',
        dateTime: dt,
        income: inc,
        expense: exp,
        netBalance: inc - exp,
        incomeCount: data['incomeCount'] as int,
        expenseCount: data['expenseCount'] as int,
      ));
    }

    return points;
  }
}
