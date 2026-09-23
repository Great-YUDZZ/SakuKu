import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../datasources/app_database.dart';
import '../models/backup_payload_model.dart';
import '../models/transaction_model.dart';
import 'transaction_repository.dart';

class BackupRestoreResult {
  final bool success;
  final String message;
  final int transactionCount;
  final String? filePath;

  const BackupRestoreResult({
    required this.success,
    required this.message,
    this.transactionCount = 0,
    this.filePath,
  });
}

class BackupRepository {
  final TransactionRepository _transactionRepo;
  final AppDatabase _dbProvider;

  BackupRepository({
    TransactionRepository? transactionRepo,
    AppDatabase? dbProvider,
  })  : _transactionRepo = transactionRepo ?? TransactionRepository(),
        _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<String> getDefaultBackupPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    final backupFolder =
        Directory(p.join(docDir.path, 'LocalFinancialManager', 'backups'));
    if (!await backupFolder.exists()) {
      await backupFolder.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    return p.join(backupFolder.path, 'backup_finance_$timestamp.json');
  }

  /// Ekspor seluruh data transaksi lokal ke file arsip terenkripsi checksum SHA-256
  Future<BackupRestoreResult> exportBackup({String? targetPath}) async {
    try {
      final items = await _transactionRepo.getAllTransactions(limit: 100000);
      final payload = BackupPayloadModel.createFromEntities(items);
      final jsonString = payload.toJsonString();

      final destinationPath = targetPath ?? await getDefaultBackupPath();
      final file = File(destinationPath);

      // Tulis atomik menggunakan file sementara untuk menghindari file korup jika crash di tengah penulisan
      final tempFile = File('$destinationPath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(destinationPath);

      return BackupRestoreResult(
        success: true,
        message: 'Cadangan berhasil diekspor (${items.length} transaksi)',
        transactionCount: items.length,
        filePath: destinationPath,
      );
    } catch (e) {
      return BackupRestoreResult(
        success: false,
        message: 'Gagal mengekspor data: $e',
      );
    }
  }

  /// Pulihkan data dari file arsip cadangan dengan validasi integritas ketat dan transaksi rollback
  Future<BackupRestoreResult> restoreBackup(String sourcePath) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) {
        return const BackupRestoreResult(
          success: false,
          message: 'File cadangan tidak ditemukan di path yang ditentukan.',
        );
      }

      final jsonContent = await file.readAsString();

      // Langkah 1: Validasi struktur skema & verifikasi checksum hash SHA-256
      final payload = BackupPayloadModel.fromJsonString(jsonContent);

      // Langkah 2: Eksekusi transaksi database (Rollback otomatis jika terjadi error)
      final db = await _dbProvider.database;
      await db.transaction((txn) async {
        // Hapus data lama dalam transaksi
        await txn.delete(TransactionModel.tableName);

        // Masukkan data baru dari cadangan
        final batch = txn.batch();
        for (final item in payload.transactions) {
          batch.insert(
            TransactionModel.tableName,
            TransactionModel.toMap(item),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });

      return BackupRestoreResult(
        success: true,
        message:
            'Data berhasil dipulihkan secara utuh (${payload.transactions.length} transaksi)',
        transactionCount: payload.transactions.length,
        filePath: sourcePath,
      );
    } on FormatException catch (fe) {
      return BackupRestoreResult(
        success: false,
        message: 'Format file tidak valid: ${fe.message}',
      );
    } catch (e) {
      return BackupRestoreResult(
        success: false,
        message: 'Pemulihan data gagal dibatalkan (Rollback aman): $e',
      );
    }
  }
}
