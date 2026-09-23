import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../data/repositories/transaction_repository.dart';

enum StatTableTab {
  comparison,
  income,
  expense,
}

class FinancialStatisticsTable extends StatefulWidget {
  final MonthlySummary? summary;

  const FinancialStatisticsTable({
    super.key,
    required this.summary,
  });

  @override
  State<FinancialStatisticsTable> createState() =>
      _FinancialStatisticsTableState();
}

class _FinancialStatisticsTableState extends State<FinancialStatisticsTable> {
  StatTableTab _currentTab = StatTableTab.comparison;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return GlassNeumorphicCard(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      borderRadius: AppDimensions.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Tab Selector
          _buildHeader(),
          const SizedBox(height: 16),

          // Content based on selected tab
          if (_currentTab == StatTableTab.comparison)
            _buildComparisonTable(summary)
          else if (_currentTab == StatTableTab.income)
            _buildCategoryStatsTable(
              title: 'Statistika Rinci Pemasukan per Kategori',
              stats: summary?.incomeStats ?? [],
              totalAmount: summary?.totalIncome ?? 0.0,
              totalCount: summary?.totalIncomeCount ?? 0,
              isIncome: true,
            )
          else
            _buildCategoryStatsTable(
              title: 'Statistika Rinci Pengeluaran per Kategori',
              stats: summary?.expenseStats ?? [],
              totalAmount: summary?.totalExpense ?? 0.0,
              totalCount: summary?.totalExpenseCount ?? 0,
              isIncome: false,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        final titleWidget = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.table_chart_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tabel Statistika Finansial',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Analisis komparasi dan rincian alokasi dana bulanan',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final tabsWidget = Container(
          decoration: BoxDecoration(
            color: AppColors.cardInner,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: AppColors.borderMedium, width: 1.0),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _buildTabButton(
                tab: StatTableTab.comparison,
                label: 'Ringkasan',
                icon: Icons.compare_arrows_rounded,
                isCompact: isCompact,
              ),
              _buildTabButton(
                tab: StatTableTab.income,
                label: 'Pemasukan',
                icon: Icons.arrow_downward_rounded,
                activeColor: AppColors.income,
                isCompact: isCompact,
              ),
              _buildTabButton(
                tab: StatTableTab.expense,
                label: 'Pengeluaran',
                icon: Icons.arrow_upward_rounded,
                activeColor: AppColors.expense,
                isCompact: isCompact,
              ),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const SizedBox(height: 12),
              tabsWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleWidget),
            const SizedBox(width: 12),
            tabsWidget,
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required StatTableTab tab,
    required String label,
    required IconData icon,
    Color activeColor = AppColors.primary,
    bool isCompact = false,
  }) {
    final isSelected = _currentTab == tab;

    final child = GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppDimensions.durationMicro,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton - 2),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isCompact) {
      return Expanded(child: child);
    }
    return child;
  }

  // --- TAB 1: COMPARISON / CASHFLOW SUMMARY TABLE ---
  Widget _buildComparisonTable(MonthlySummary? summary) {
    final totalIncome = summary?.totalIncome ?? 0.0;
    final totalExpense = summary?.totalExpense ?? 0.0;
    final balance = summary?.balance ?? 0.0;
    final incomeCount = summary?.totalIncomeCount ?? 0;
    final expenseCount = summary?.totalExpenseCount ?? 0;
    final maxIncome = summary?.maxIncome ?? 0.0;
    final maxExpense = summary?.maxExpense ?? 0.0;

    final avgIncome = incomeCount > 0 ? totalIncome / incomeCount : 0.0;
    final avgExpense = expenseCount > 0 ? totalExpense / expenseCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  horizontalMargin: 12,
                  columnSpacing: 20,
                  headingRowHeight: 38,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 46,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.cardInner,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'METRIK ARUS KAS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PEMASUKAN (INCOME)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.income,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PENGELUARAN (EXPENSE)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.expense,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SALDO / SELISIH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Total Akumulasi Nominal',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(totalIncome),
                            style: const TextStyle(
                              color: AppColors.income,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(totalExpense),
                            style: const TextStyle(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(balance),
                            style: TextStyle(
                              color: balance >= 0 ? AppColors.primary : AppColors.expense,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Frekuensi Transaksi',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        DataCell(Text('$incomeCount transaksi', style: const TextStyle(fontSize: 13))),
                        DataCell(Text('$expenseCount transaksi', style: const TextStyle(fontSize: 13))),
                        DataCell(
                          Text(
                            '${incomeCount + expenseCount} total aktivitas',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Rata-rata per Transaksi',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            incomeCount > 0 ? CurrencyFormatter.format(avgIncome) : '-',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            expenseCount > 0 ? CurrencyFormatter.format(avgExpense) : '-',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            totalIncome > 0
                                ? 'Rasio Simpan: ${((balance / totalIncome) * 100).toStringAsFixed(1)}%'
                                : '-',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Transaksi Terbesar (Max)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            maxIncome > 0 ? CurrencyFormatter.format(maxIncome) : '-',
                            style: const TextStyle(fontSize: 13, color: AppColors.income),
                          ),
                        ),
                        DataCell(
                          Text(
                            maxExpense > 0 ? CurrencyFormatter.format(maxExpense) : '-',
                            style: const TextStyle(fontSize: 13, color: AppColors.expense),
                          ),
                        ),
                        DataCell(
                          Text(
                            balance >= 0 ? 'Surplus Aman' : 'Defisit Anggaran',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: balance >= 0 ? AppColors.income : AppColors.expense,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 2 & 3: DETAILED CATEGORY STATISTICS TABLE ---
  Widget _buildCategoryStatsTable({
    required String title,
    required List<CategoryStat> stats,
    required double totalAmount,
    required int totalCount,
    required bool isIncome,
  }) {
    if (stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              Icon(
                isIncome
                    ? Icons.savings_outlined
                    : Icons.shopping_bag_outlined,
                size: 40,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Belum ada transaksi ${isIncome ? "pemasukan" : "pengeluaran"} pada bulan ini.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final accentColor = isIncome ? AppColors.income : AppColors.expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  horizontalMargin: 12,
                  columnSpacing: 18,
                  headingRowHeight: 38,
                  dataRowMinHeight: 44,
                  dataRowMaxHeight: 48,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.cardInner,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'KATEGORI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'JUMLAH (TX)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'TOTAL NOMINAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PORSI (%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'RATA-RATA / TX',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...stats.map((stat) {
                      final cat = stat.category;
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: cat.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(cat.icon, size: 14, color: cat.color),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '${stat.count}x',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              CurrencyFormatter.format(stat.totalAmount),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 45,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: (stat.percentage / 100.0).clamp(0.0, 1.0),
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${stat.percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              CurrencyFormatter.format(stat.averageAmount),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Footer Row: Total
                    DataRow(
                      color: WidgetStateProperty.all(AppColors.cardInner),
                      cells: [
                        const DataCell(
                          Text(
                            'TOTAL KESELURUHAN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$totalCount transaksi',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(totalAmount),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const DataCell(
                          Text(
                            '100.0%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            totalCount > 0
                                ? CurrencyFormatter.format(totalAmount / totalCount)
                                : '-',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
