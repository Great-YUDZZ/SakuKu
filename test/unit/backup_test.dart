import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/data/models/backup_payload_model.dart';
import 'package:local_financial_manager/domain/models/transaction_entity.dart';

void main() {
  group('BackupPayloadModel Integrity & Validation (FR-03)', () {
    final sampleTransactions = [
      TransactionEntity(
        id: 1,
        description: 'Gaji Bulanan',
        amount: 8000000.0,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(2026, 9, 1),
        createdAt: DateTime(2026, 9, 1),
      ),
      TransactionEntity(
        id: 2,
        description: 'Belanja Supermarket',
        amount: 650000.0,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2026, 9, 5),
        createdAt: DateTime(2026, 9, 5),
      ),
    ];

    test('Harus berhasil mengekspor dan mem-parse kembali payload cadangan yang valid', () {
      final payload =
          BackupPayloadModel.createFromEntities(sampleTransactions);
      final jsonString = payload.toJsonString();

      final parsed = BackupPayloadModel.fromJsonString(jsonString);

      expect(parsed.appName, equals('LocalFinancialManager'));
      expect(parsed.transactionCount, equals(2));
      expect(parsed.transactions.length, equals(2));
      expect(parsed.transactions.first.description, equals('Gaji Bulanan'));
      expect(parsed.transactions.first.amount, equals(8000000.0));
      expect(parsed.transactions.last.description, equals('Belanja Supermarket'));
    });

    test('Harus melempar FormatException jika checksum SHA-256 tidak cocok (data dimanipulasi)', () {
      final payload =
          BackupPayloadModel.createFromEntities(sampleTransactions);
      final map = payload.toMap();

      // Memanipulasi nominal secara manual tanpa memperbarui checksum
      final transactions = map['transactions'] as List;
      (transactions[0] as Map)['amount'] = 999999999.0;

      final modifiedJson =
          '{"version":1,"app_name":"LocalFinancialManager","exported_at":"${map['exported_at']}","transaction_count":2,"checksum":"${map['checksum']}","transactions":[{"description":"Gaji","amount":999999999.0,"type":"income","category":"salary","date":"2026-09-01T00:00:00.000","created_at":"2026-09-01T00:00:00.000"}]}';

      expect(
        () => BackupPayloadModel.fromJsonString(modifiedJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('Harus menolak file cadangan jika bukan dari LocalFinancialManager', () {
      const invalidAppJson = '''
      {
        "version": 1,
        "app_name": "AnotherApp",
        "exported_at": "2026-09-21T00:00:00.000",
        "transaction_count": 0,
        "checksum": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "transactions": []
      }
      ''';

      expect(
        () => BackupPayloadModel.fromJsonString(invalidAppJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
