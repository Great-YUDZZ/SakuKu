import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/models/transaction_entity.dart';
import 'transaction_model.dart';

class BackupPayloadModel {
  static const int currentSchemaVersion = 1;
  static const String appIdentifier = 'LocalFinancialManager';

  final int version;
  final String appName;
  final String exportedAt;
  final int transactionCount;
  final String checksum;
  final List<TransactionEntity> transactions;

  const BackupPayloadModel({
    required this.version,
    required this.appName,
    required this.exportedAt,
    required this.transactionCount,
    required this.checksum,
    required this.transactions,
  });

  static String generateChecksum(List<Map<String, dynamic>> rawList) {
    final serialized = jsonEncode(rawList);
    return sha256.convert(utf8.encode(serialized)).toString();
  }

  static BackupPayloadModel createFromEntities(List<TransactionEntity> items) {
    final rawList = items.map((e) => TransactionModel.toMap(e)).toList();
    final checksum = generateChecksum(rawList);

    return BackupPayloadModel(
      version: currentSchemaVersion,
      appName: appIdentifier,
      exportedAt: DateTime.now().toIso8601String(),
      transactionCount: items.length,
      checksum: checksum,
      transactions: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'app_name': appName,
      'exported_at': exportedAt,
      'transaction_count': transactionCount,
      'checksum': checksum,
      'transactions':
          transactions.map((e) => TransactionModel.toMap(e)).toList(),
    };
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  /// Memverifikasi dan mem-parsing isi file JSON cadangan.
  /// Melempar Exception jika integritas checksum rusak atau skema tidak valid.
  static BackupPayloadModel fromJsonString(String jsonContent) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } catch (e) {
      throw FormatException('Format file JSON cadangan tidak valid: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Payload file cadangan harus berupa JSON Object.');
    }

    final appName = decoded['app_name'] as String?;
    if (appName != appIdentifier) {
      throw const FormatException('File cadangan bukan berasal dari Local Financial Manager.');
    }

    final rawTransactions = decoded['transactions'];
    if (rawTransactions is! List) {
      throw const FormatException('Data transaksi pada file cadangan tidak valid.');
    }

    final List<Map<String, dynamic>> castedList = [];
    for (var item in rawTransactions) {
      if (item is Map<String, dynamic>) {
        castedList.add(item);
      } else if (item is Map) {
        castedList.add(Map<String, dynamic>.from(item));
      } else {
        throw const FormatException('Ditemukan item transaksi korup di file cadangan.');
      }
    }

    final expectedChecksum = decoded['checksum'] as String?;
    final calculatedChecksum = generateChecksum(castedList);

    if (expectedChecksum != calculatedChecksum) {
      throw const FormatException(
        'Integritas data cadangan rusak (Checksum SHA-256 tidak cocok). Proses dibatalkan.',
      );
    }

    final transactions =
        castedList.map((m) => TransactionModel.fromMap(m)).toList();

    return BackupPayloadModel(
      version: (decoded['version'] as int?) ?? currentSchemaVersion,
      appName: appName ?? appIdentifier,
      exportedAt: (decoded['exported_at'] as String?) ?? '',
      transactionCount: (decoded['transaction_count'] as int?) ?? transactions.length,
      checksum: calculatedChecksum,
      transactions: transactions,
    );
  }
}
