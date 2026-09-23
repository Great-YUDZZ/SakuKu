import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/transaction_entity.dart';

/// Interactive Pie/Donut Chart for visualizing Income and Expense source distribution
/// grouped by TransactionCategory with interactive hover/touch highlight and center info.
class CategoryPieChart extends StatefulWidget {
  final MonthlySummary? summary;

  const CategoryPieChart({
    super.key,
    required this.summary,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  TransactionType _selectedType = TransactionType.expense;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == TransactionType.expense;
    final stats = isExpense
        ? (widget.summary?.expenseStats ?? const <CategoryStat>[])
        : (widget.summary?.incomeStats ?? const <CategoryStat>[]);
    final totalAmount = isExpense
        ? (widget.summary?.totalExpense ?? 0.0)
        : (widget.summary?.totalIncome ?? 0.0);

    return GlassNeumorphicCard(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      borderRadius: AppDimensions.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isExpense, stats.length),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            _buildEmptyState(isExpense)
          else
            _buildChartContent(stats, totalAmount, isExpense),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isExpense, int categoryCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        final titleRow = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: (isExpense ? AppColors.expense : AppColors.income)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.donut_large_rounded,
                color: isExpense ? AppColors.expense : AppColors.income,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribusi Kategori (${isExpense ? "Pengeluaran" : "Pemasukan"})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Diagram lingkaran proporsi alokasi dana per kategori',
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

        final typeTabs = Container(
          decoration: BoxDecoration(
            color: AppColors.cardInner,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: AppColors.borderMedium, width: 1.0),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _buildTypeButton(
                type: TransactionType.expense,
                label: 'Pengeluaran',
                icon: Icons.arrow_downward_rounded,
                activeColor: AppColors.expense,
                isNarrow: isNarrow,
              ),
              _buildTypeButton(
                type: TransactionType.income,
                label: 'Pemasukan',
                icon: Icons.arrow_upward_rounded,
                activeColor: AppColors.income,
                isNarrow: isNarrow,
              ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: 12),
              typeTabs,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleRow),
            const SizedBox(width: 12),
            typeTabs,
          ],
        );
      },
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color activeColor,
    bool isNarrow = false,
  }) {
    final isSelected = _selectedType == type;

    final child = GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
            _hoveredIndex = null;
          });
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppDimensions.durationMicro,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 10 : 12,
            vertical: 5,
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
                size: 13,
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

    if (isNarrow) {
      return Expanded(child: child);
    }
    return child;
  }

  Widget _buildEmptyState(bool isExpense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardInner.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpense ? Icons.receipt_long_outlined : Icons.account_balance_wallet_outlined,
            size: 40,
            color: AppColors.textMuted.withOpacity(0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada catatan ${isExpense ? "pengeluaran" : "pemasukan"} pada periode ini',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Tambahkan transaksi untuk melihat visualisasi diagram lingkaran per kategori',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(
    List<CategoryStat> stats,
    double totalAmount,
    bool isExpense,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Donut Chart with Center Display
              Expanded(
                flex: 5,
                child: _buildDonutCanvas(stats, totalAmount, isExpense),
              ),
              const SizedBox(width: 20),
              // Right: Category Legend & Breakdown List
              Expanded(
                flex: 5,
                child: _buildCategoryList(stats, totalAmount, isExpense),
              ),
            ],
          );
        }

        // Mobile/Narrow View: Stacked vertically
        return Column(
          children: [
            _buildDonutCanvas(stats, totalAmount, isExpense),
            const SizedBox(height: 18),
            _buildCategoryList(stats, totalAmount, isExpense),
          ],
        );
      },
    );
  }

  Widget _buildDonutCanvas(
    List<CategoryStat> stats,
    double totalAmount,
    bool isExpense,
  ) {
    const chartSize = 220.0;

    CategoryStat? activeStat;
    if (_hoveredIndex != null &&
        _hoveredIndex! >= 0 &&
        _hoveredIndex! < stats.length) {
      activeStat = stats[_hoveredIndex!];
    }

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: MouseRegion(
          onHover: (event) => _handlePointerHover(event.localPosition, chartSize, stats),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: GestureDetector(
            onPanDown: (details) => _handlePointerHover(details.localPosition, chartSize, stats),
            onPanUpdate: (details) => _handlePointerHover(details.localPosition, chartSize, stats),
            onTapUp: (details) => _handlePointerHover(details.localPosition, chartSize, stats),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Painter Donut Slices
                CustomPaint(
                  size: const Size(chartSize, chartSize),
                  painter: _CategoryDonutPainter(
                    stats: stats,
                    totalAmount: totalAmount,
                    hoveredIndex: _hoveredIndex,
                  ),
                ),
                // Center Cutout Card (Dynamic on Hover/Tap)
                _buildCenterInfo(activeStat, totalAmount, isExpense),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterInfo(
    CategoryStat? activeStat,
    double totalAmount,
    bool isExpense,
  ) {
    const centerDiameter = 120.0;

    return Container(
      width: centerDiameter,
      height: centerDiameter,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: activeStat != null
              ? activeStat.category.color.withOpacity(0.5)
              : AppColors.borderSubtle,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (activeStat != null) ...[
            Icon(
              activeStat.category.icon,
              size: 20,
              color: activeStat.category.color,
            ),
            const SizedBox(height: 2),
            Text(
              activeStat.category.label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '${activeStat.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: activeStat.category.color,
              ),
            ),
            Text(
              CurrencyFormatter.format(activeStat.totalAmount),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              isExpense ? 'TOTAL PENGELUARAN' : 'TOTAL PEMASUKAN',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              CurrencyFormatter.format(totalAmount),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: isExpense ? AppColors.expense : AppColors.income,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            const Text(
              'Sentuh untuk rincian',
              style: TextStyle(
                fontSize: 8.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    List<CategoryStat> stats,
    double totalAmount,
    bool isExpense,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RINCIAN SUMBER & KATEGORI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              '${stats.length} Kategori',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = stats[index];
            final isHovered = _hoveredIndex == index;

            return MouseRegion(
              onEnter: (_) => setState(() => _hoveredIndex = index),
              onExit: (_) => setState(() => _hoveredIndex = null),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hoveredIndex = (_hoveredIndex == index) ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: AppDimensions.durationMicro,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? item.category.color.withOpacity(0.09)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    border: Border.all(
                      color: isHovered
                          ? item.category.color.withOpacity(0.6)
                          : AppColors.borderSubtle,
                      width: isHovered ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Category Color & Icon Box
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: item.category.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          item.category.icon,
                          size: 16,
                          color: item.category.color,
                        ),
                      ),
                      const SizedBox(width: 9),
                      // Label & Frequency
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isHovered
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${item.count} transaksi • Rata-rata ${CurrencyFormatter.format(item.averageAmount)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Percentage Badge & Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.category.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: item.category.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(item.totalAmount),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handlePointerHover(
    Offset localPos,
    double chartSize,
    List<CategoryStat> stats,
  ) {
    final center = Offset(chartSize / 2.0, chartSize / 2.0);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    final outerRadius = chartSize / 2.0;
    const innerRadius = 60.0; // matching center cutout radius

    // Outside donut ring
    if (dist < innerRadius || dist > outerRadius + 8) {
      if (_hoveredIndex != null) setState(() => _hoveredIndex = null);
      return;
    }

    // Angle in radians [-pi, pi]
    double angle = math.atan2(dy, dx);
    // Align with start angle: -pi / 2 (12 o'clock)
    double normalized = angle - (-math.pi / 2.0);
    while (normalized < 0) {
      normalized += 2 * math.pi;
    }
    while (normalized >= 2 * math.pi) {
      normalized -= 2 * math.pi;
    }

    // Find which slice covers this normalized angle
    double currentAngle = 0.0;
    int? matchedIndex;

    for (int i = 0; i < stats.length; i++) {
      final sweep = (stats[i].percentage / 100.0) * (2 * math.pi);
      if (normalized >= currentAngle && normalized < currentAngle + sweep) {
        matchedIndex = i;
        break;
      }
      currentAngle += sweep;
    }

    if (_hoveredIndex != matchedIndex) {
      setState(() => _hoveredIndex = matchedIndex);
    }
  }
}

/// CustomPainter for rendering high-precision Donut chart slices with gaps and hover expansion
class _CategoryDonutPainter extends CustomPainter {
  final List<CategoryStat> stats;
  final double totalAmount;
  final int? hoveredIndex;

  _CategoryDonutPainter({
    required this.stats,
    required this.totalAmount,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty || totalAmount <= 0) return;

    final center = Offset(size.width / 2.0, size.height / 2.0);
    final baseRadius = (size.width / 2.0) - 6.0;
    const innerRadius = 62.0;

    double startAngle = -math.pi / 2.0; // Start at 12 o'clock

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < stats.length; i++) {
      final stat = stats[i];
      final sweepAngle = (stat.percentage / 100.0) * (2 * math.pi);
      if (sweepAngle <= 0.001) continue;

      final isHovered = (hoveredIndex == i);

      // Expansion effect on hovered slice
      final currentRadius = isHovered ? baseRadius + 4.0 : baseRadius;
      final strokeWidth = isHovered ? (currentRadius - innerRadius + 3) : (currentRadius - innerRadius);
      final midRadius = innerRadius + (strokeWidth / 2.0);

      linePaint
        ..color = isHovered ? stat.category.color : stat.category.color.withOpacity(0.92)
        ..strokeWidth = strokeWidth;

      // Draw arc
      // Small gap between slices if more than 1 slice exists
      final gap = stats.length > 1 ? 0.03 : 0.0;
      final effectiveSweep = math.max(0.01, sweepAngle - gap);
      final effectiveStart = startAngle + (gap / 2.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: midRadius),
        effectiveStart,
        effectiveSweep,
        false,
        linePaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) {
    return oldDelegate.stats != stats ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.totalAmount != totalAmount;
  }
}
