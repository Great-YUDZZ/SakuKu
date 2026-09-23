import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/debt_model.dart';
import '../models/investment_model.dart';
import '../models/transaction_model.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _dbFileName = 'local_finance_manager.db';
  static const int _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Inisialisasi engine FFI untuk platform desktop (Linux, Windows, macOS)
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      if (Platform.isLinux) {
        open.overrideFor(OperatingSystem.linux, () {
          try {
            return DynamicLibrary.open('libsqlite3.so.0');
          } catch (_) {
            return DynamicLibrary.open('libsqlite3.so');
          }
        });
      }
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfiNoIsolate;
    }

    final String dbPath;
    if (kIsWeb) {
      dbPath = _dbFileName;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDir = Directory(p.join(appDocDir.path, 'LocalFinancialManager'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      dbPath = p.join(appDir.path, _dbFileName);
    }

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TransactionModel.tableName} (
        ${TransactionModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TransactionModel.colDescription} TEXT NOT NULL,
        ${TransactionModel.colAmount} REAL NOT NULL,
        ${TransactionModel.colType} TEXT NOT NULL,
        ${TransactionModel.colCategory} TEXT NOT NULL,
        ${TransactionModel.colDate} TEXT NOT NULL,
        ${TransactionModel.colCreatedAt} TEXT NOT NULL
      )
    ''');

    // Indexing untuk kecepatan pencarian transaksi (< 50ms untuk 10.000 data)
    await db.execute('''
      CREATE INDEX idx_trans_date ON ${TransactionModel.tableName} (${TransactionModel.colDate})
    ''');
    await db.execute('''
      CREATE INDEX idx_trans_type ON ${TransactionModel.tableName} (${TransactionModel.colType})
    ''');

    // Buat tabel debts dan investments
    await _createPortfolioTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createPortfolioTables(db);
    }
  }

  Future<void> _createPortfolioTables(Database db) async {
    // Tabel Debts (Hutang & Piutang)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DebtModel.tableName} (
        ${DebtModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DebtModel.colTitle} TEXT NOT NULL,
        ${DebtModel.colType} TEXT NOT NULL,
        ${DebtModel.colPerson} TEXT NOT NULL,
        ${DebtModel.colAmount} REAL NOT NULL,
        ${DebtModel.colRemainingAmount} REAL NOT NULL,
        ${DebtModel.colInterestRate} REAL NOT NULL,
        ${DebtModel.colInterestType} TEXT NOT NULL,
        ${DebtModel.colStartDate} TEXT NOT NULL,
        ${DebtModel.colDueDate} TEXT NOT NULL,
        ${DebtModel.colStatus} TEXT NOT NULL,
        ${DebtModel.colNotes} TEXT,
        ${DebtModel.colCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_debts_due ON ${DebtModel.tableName} (${DebtModel.colDueDate})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_debts_status ON ${DebtModel.tableName} (${DebtModel.colStatus})
    ''');

    // Tabel Investments (Saham, Reksadana, Crypto, dll.)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${InvestmentModel.tableName} (
        ${InvestmentModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${InvestmentModel.colName} TEXT NOT NULL,
        ${InvestmentModel.colCategory} TEXT NOT NULL,
        ${InvestmentModel.colPlatform} TEXT NOT NULL,
        ${InvestmentModel.colInvestedAmount} REAL NOT NULL,
        ${InvestmentModel.colCurrentValue} REAL NOT NULL,
        ${InvestmentModel.colTargetAmount} REAL,
        ${InvestmentModel.colExpectedReturnRate} REAL NOT NULL,
        ${InvestmentModel.colStartDate} TEXT NOT NULL,
        ${InvestmentModel.colMaturityDate} TEXT,
        ${InvestmentModel.colNotes} TEXT,
        ${InvestmentModel.colCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_invest_cat ON ${InvestmentModel.tableName} (${InvestmentModel.colCategory})
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
