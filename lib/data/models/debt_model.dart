import '../../domain/models/debt_entity.dart';

class DebtModel {
  static const String tableName = 'debts';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colType = 'type';
  static const String colPerson = 'person_or_institution';
  static const String colAmount = 'amount';
  static const String colRemainingAmount = 'remaining_amount';
  static const String colInterestRate = 'interest_rate';
  static const String colInterestType = 'interest_type';
  static const String colStartDate = 'start_date';
  static const String colDueDate = 'due_date';
  static const String colStatus = 'status';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';

  final DebtEntity entity;

  const DebtModel(this.entity);

  factory DebtModel.fromEntity(DebtEntity entity) => DebtModel(entity);

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      DebtEntity(
        id: map[colId] as int?,
        title: map[colTitle] as String? ?? '',
        type: DebtType.fromKey(map[colType] as String?),
        personOrInstitution: map[colPerson] as String? ?? '',
        amount: ((map[colAmount] as num?) ?? 0.0).toDouble(),
        remainingAmount: ((map[colRemainingAmount] as num?) ?? 0.0).toDouble(),
        interestRate: ((map[colInterestRate] as num?) ?? 0.0).toDouble(),
        interestType: InterestType.fromKey(map[colInterestType] as String?),
        startDate: DateTime.tryParse(map[colStartDate] as String? ?? '') ?? DateTime.now(),
        dueDate: DateTime.tryParse(map[colDueDate] as String? ?? '') ?? DateTime.now(),
        status: DebtStatus.fromKey(map[colStatus] as String?),
        notes: map[colNotes] as String?,
        createdAt: DateTime.tryParse(map[colCreatedAt] as String? ?? '') ?? DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      colTitle: entity.title,
      colType: entity.type.name,
      colPerson: entity.personOrInstitution,
      colAmount: entity.amount,
      colRemainingAmount: entity.remainingAmount,
      colInterestRate: entity.interestRate,
      colInterestType: entity.interestType.name,
      colStartDate: entity.startDate.toIso8601String(),
      colDueDate: entity.dueDate.toIso8601String(),
      colStatus: entity.status.name,
      colNotes: entity.notes,
      colCreatedAt: entity.createdAt.toIso8601String(),
    };
    if (entity.id != null) {
      map[colId] = entity.id;
    }
    return map;
  }
}
