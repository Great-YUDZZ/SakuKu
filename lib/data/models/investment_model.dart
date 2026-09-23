import '../../domain/models/investment_entity.dart';

class InvestmentModel {
  static const String tableName = 'investments';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCategory = 'category';
  static const String colPlatform = 'platform';
  static const String colInvestedAmount = 'invested_amount';
  static const String colCurrentValue = 'current_value';
  static const String colTargetAmount = 'target_amount';
  static const String colExpectedReturnRate = 'expected_return_rate';
  static const String colStartDate = 'start_date';
  static const String colMaturityDate = 'maturity_date';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';

  final InvestmentEntity entity;

  const InvestmentModel(this.entity);

  factory InvestmentModel.fromEntity(InvestmentEntity entity) => InvestmentModel(entity);

  factory InvestmentModel.fromMap(Map<String, dynamic> map) {
    return InvestmentModel(
      InvestmentEntity(
        id: map[colId] as int?,
        name: map[colName] as String? ?? '',
        category: InvestmentCategory.fromKey(map[colCategory] as String?),
        platform: map[colPlatform] as String? ?? '',
        investedAmount: ((map[colInvestedAmount] as num?) ?? 0.0).toDouble(),
        currentValue: ((map[colCurrentValue] as num?) ?? 0.0).toDouble(),
        targetAmount: (map[colTargetAmount] as num?)?.toDouble(),
        expectedReturnRate: ((map[colExpectedReturnRate] as num?) ?? 0.0).toDouble(),
        startDate: DateTime.tryParse(map[colStartDate] as String? ?? '') ?? DateTime.now(),
        maturityDate: DateTime.tryParse(map[colMaturityDate] as String? ?? ''),
        notes: map[colNotes] as String?,
        createdAt: DateTime.tryParse(map[colCreatedAt] as String? ?? '') ?? DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      colName: entity.name,
      colCategory: entity.category.name,
      colPlatform: entity.platform,
      colInvestedAmount: entity.investedAmount,
      colCurrentValue: entity.currentValue,
      colTargetAmount: entity.targetAmount,
      colExpectedReturnRate: entity.expectedReturnRate,
      colStartDate: entity.startDate.toIso8601String(),
      colMaturityDate: entity.maturityDate?.toIso8601String(),
      colNotes: entity.notes,
      colCreatedAt: entity.createdAt.toIso8601String(),
    };
    if (entity.id != null) {
      map[colId] = entity.id;
    }
    return map;
  }
}
