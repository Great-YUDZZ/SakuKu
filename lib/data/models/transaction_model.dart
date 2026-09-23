import '../../domain/models/transaction_entity.dart';

class TransactionModel {
  static const String tableName = 'transactions';

  static const String colId = 'id';
  static const String colDescription = 'description';
  static const String colAmount = 'amount';
  static const String colType = 'type';
  static const String colCategory = 'category';
  static const String colDate = 'date';
  static const String colCreatedAt = 'created_at';

  static Map<String, dynamic> toMap(TransactionEntity entity) {
    return {
      if (entity.id != null) colId: entity.id,
      colDescription: entity.description,
      colAmount: entity.amount,
      colType: entity.type.name,
      colCategory: entity.category.name,
      colDate: entity.date.toIso8601String(),
      colCreatedAt: entity.createdAt.toIso8601String(),
    };
  }

  static TransactionEntity fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map[colId] as int?,
      description: (map[colDescription] as String?) ?? '',
      amount: ((map[colAmount] as num?) ?? 0.0).toDouble(),
      type: (map[colType] as String?) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: TransactionCategory.fromKey(map[colCategory] as String?),
      date: DateTime.tryParse(map[colDate] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map[colCreatedAt] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> toJson(TransactionEntity entity) => toMap(entity);
  static TransactionEntity fromJson(Map<String, dynamic> json) => fromMap(json);
}
