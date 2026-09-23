import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../data/repositories/transaction_repository.dart';

class FinancialCashflowChart extends StatefulWidget {
  final DateTime selectedMonth;
  final TransactionRepository? repository;

  const FinancialCashflowChart({
    super.key,
    required this.selectedMonth,
    this.repository,
  });

  @override
  State<FinancialCashflowChart> createState() => _FinancialCashflowChartState();
}

class _FinancialCashflowChartState extends State<FinancialCashflowChart> {
  late final TransactionRepository _repository;
  TimeGranularity _granularity = TimeGranularity.daily;

  List<TimePointCashFlow> _dataPoints = [];
  bool _isLoading = true;
  int? _hoveredIndex;
  Offset? _hoverPosition;
  bool _showDetailsTable = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TransactionRepository();
    _fetchChartData();
  }

  @override
  void didUpdateWidget(covariant FinancialCashflowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _fetchChartData();
    }
  }

  Future<void> _fetchChartData() async {
    setState(() => _isLoading = true);
    try {
      List<TimePointCashFlow> points;
      switch (_granularity) {
        case TimeGranularity.daily:
          points = await _repository.getDailyCashFlow(widget.selectedMonth);
          break;
        case TimeGranularity.monthly:
          points = await _repository.getMonthlyCashFlow(widget.selectedMonth.year);
          break;
        case TimeGranularity.yearly:
          points = await _repository.getYearlyCashFlow();
          break;
      }
      if (mounted) {
        setState(() {
          _dataPoints = points;
          _hoveredIndex = null;
          _hoverPosition = null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassNeumorphicCard(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      borderRadius: AppDimensions.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Granularity Tabs (Hari, Bulan, Tahun)
          _buildHeader(),
          const SizedBox(height: 16),

          // Main Chart Canvas with Interactive Tooltip
          if (_isLoading)
            const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_dataPoints.isEmpty)
            const SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'Belum ada data transaksi pada rentang waktu ini.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            _buildInteractiveChartSection(),

          const SizedBox(height: 12),

          // Bottom Legend and Details Toggle
          _buildBottomLegendAndActions(),

          // Optional Expandable Details Table
          if (_showDetailsTable && _dataPoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),
            _buildExpandableDetailsTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        final titleWidget = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics_rounded,
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
                    'Grafik Arus Kas Finansial',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Naik (+) Pemasukan • Turun (-) Pengeluaran • Geser untuk rincian',
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
              _buildGranularityButton(
                granularity: TimeGranularity.daily,
                label: 'Hari',
                icon: Icons.calendar_today_rounded,
                isCompact: isCompact,
              ),
              _buildGranularityButton(
                granularity: TimeGranularity.monthly,
                label: 'Bulan',
                icon: Icons.date_range_rounded,
                isCompact: isCompact,
              ),
              _buildGranularityButton(
                granularity: TimeGranularity.yearly,
                label: 'Tahun',
                icon: Icons.event_note_rounded,
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

  Widget _buildGranularityButton({
    required TimeGranularity granularity,
    required String label,
    required IconData icon,
    bool isCompact = false,
  }) {
    final isSelected = _granularity == granularity;

    final child = GestureDetector(
      onTap: () {
        if (_granularity != granularity) {
          setState(() => _granularity = granularity);
          _fetchChartData();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppDimensions.durationMicro,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 14,
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
                size: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

  // --- INTERACTIVE CHART CANVAS ---
  Widget _buildInteractiveChartSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        const chartHeight = 280.0;

        return MouseRegion(
          onHover: (event) => _handlePointerMove(event.localPosition, chartWidth),
          onExit: (_) => setState(() {
            _hoveredIndex = null;
            _hoverPosition = null;
          }),
          child: GestureDetector(
            onPanDown: (details) => _handlePointerMove(details.localPosition, chartWidth),
            onPanUpdate: (details) => _handlePointerMove(details.localPosition, chartWidth),
            onTapUp: (details) => _handlePointerMove(details.localPosition, chartWidth),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size(chartWidth, chartHeight),
                  painter: _BiDirectionalCashflowPainter(
                    dataPoints: _dataPoints,
                    hoveredIndex: _hoveredIndex,
                    hoverPosition: _hoverPosition,
                  ),
                ),
                // Floating Tooltip Preview Card matching the user's screenshot
                if (_hoveredIndex != null &&
                    _hoveredIndex! >= 0 &&
                    _hoveredIndex! < _dataPoints.length &&
                    _hoverPosition != null)
                  _buildFloatingTooltip(
                    point: _dataPoints[_hoveredIndex!],
                    chartWidth: chartWidth,
                    chartHeight: chartHeight,
                    hoverX: _hoverPosition!.dx,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePointerMove(Offset localPos, double chartWidth) {
    if (_dataPoints.isEmpty) return;

    const leftPadding = 55.0;
    const rightPadding = 15.0;
    final usableWidth = chartWidth - leftPadding - rightPadding;
    if (usableWidth <= 0) return;

    final relativeX = (localPos.dx - leftPadding).clamp(0.0, usableWidth);
    final count = _dataPoints.length;
    final step = usableWidth / math.max(1, count - 1);

    int index = (relativeX / step).round().clamp(0, count - 1);

    setState(() {
      _hoveredIndex = index;
      _hoverPosition = localPos;
    });
  }

  // --- FLOATING PREVIEW CARD (MATCHING USER SCREENSHOT) ---
  Widget _buildFloatingTooltip({
    required TimePointCashFlow point,
    required double chartWidth,
    required double chartHeight,
    required double hoverX,
  }) {
    const tooltipWidth = 230.0;
    // Smart horizontal clamping: show on left or right of cursor depending on screen edge
    double left = hoverX + 15;
    if (left + tooltipWidth > chartWidth) {
      left = hoverX - tooltipWidth - 15;
    }
    if (left < 10) left = 10;

    return Positioned(
      left: left,
      top: 15,
      child: IgnorePointer(
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.96),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF475569),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    point.fullPeriodLabel,
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Icon(
                    Icons.touch_app_outlined,
                    color: Color(0xFF94A3B8),
                    size: 13,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 8),

              // Income Row
              _buildTooltipMetricRow(
                color: const Color(0xFF10B981),
                label: 'Pemasukan (Naik)',
                value: CurrencyFormatter.format(point.income),
                count: point.incomeCount,
              ),
              const SizedBox(height: 6),

              // Expense Row
              _buildTooltipMetricRow(
                color: const Color(0xFFEF4444),
                label: 'Pengeluaran (Turun)',
                value: CurrencyFormatter.format(point.expense),
                count: point.expenseCount,
              ),
              const SizedBox(height: 6),

              // Net Balance Row
              _buildTooltipMetricRow(
                color: point.netBalance >= 0
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFFF87171),
                label: 'Saldo Bersih',
                value: CurrencyFormatter.format(point.netBalance),
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipMetricRow({
    required Color color,
    required String label,
    required String value,
    int? count,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
            if (count != null && count > 0)
              Text(
                '$count transaksi',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9.5,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- BOTTOM LEGEND & ACTIONS ---
  Widget _buildBottomLegendAndActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        final legendItems = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(
              color: AppColors.income,
              label: 'Pemasukan (Naik)',
              icon: Icons.arrow_upward_rounded,
            ),
            const SizedBox(width: 14),
            _buildLegendItem(
              color: AppColors.expense,
              label: 'Pengeluaran (Turun)',
              icon: Icons.arrow_downward_rounded,
            ),
            const SizedBox(width: 14),
            _buildLegendItem(
              color: AppColors.primary,
              label: 'Tren Saldo',
              isLine: true,
            ),
          ],
        );

        final toggleButton = TextButton.icon(
          onPressed: () => setState(() => _showDetailsTable = !_showDetailsTable),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
          icon: Icon(
            _showDetailsTable
                ? Icons.keyboard_arrow_up_rounded
                : Icons.table_rows_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          label: Text(
            _showDetailsTable ? 'Sembunyikan Tabel' : 'Lihat Data Tabel',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: legendItems,
              ),
              const SizedBox(height: 6),
              Align(alignment: Alignment.centerRight, child: toggleButton),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            legendItems,
            toggleButton,
          ],
        );
      },
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    IconData? icon,
    bool isLine = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLine)
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- EXPANDABLE NUMERICAL TABLE ---
  Widget _buildExpandableDetailsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 42,
        horizontalMargin: 8,
        columnSpacing: 18,
        headingRowColor: WidgetStateProperty.all(AppColors.cardInner),
        columns: const [
          DataColumn(
            label: Text(
              'PERIODE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'PEMASUKAN (+)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.income,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'PENGELUARAN (-)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.expense,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'SALDO BERSIH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        rows: _dataPoints.map((pt) {
          return DataRow(
            cells: [
              DataCell(Text(pt.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
              DataCell(
                Text(
                  pt.income > 0 ? CurrencyFormatter.format(pt.income) : '-',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: pt.income > 0 ? AppColors.income : AppColors.textMuted,
                  ),
                ),
              ),
              DataCell(
                Text(
                  pt.expense > 0 ? CurrencyFormatter.format(pt.expense) : '-',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: pt.expense > 0 ? AppColors.expense : AppColors.textMuted,
                  ),
                ),
              ),
              DataCell(
                Text(
                  CurrencyFormatter.format(pt.netBalance),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: pt.netBalance >= 0 ? AppColors.primary : AppColors.expense,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// --- BI-DIRECTIONAL CASH FLOW CUSTOM PAINTER ---
class _BiDirectionalCashflowPainter extends CustomPainter {
  final List<TimePointCashFlow> dataPoints;
  final int? hoveredIndex;
  final Offset? hoverPosition;

  _BiDirectionalCashflowPainter({
    required this.dataPoints,
    required this.hoveredIndex,
    required this.hoverPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    const leftPadding = 55.0;
    const rightPadding = 15.0;
    const topPadding = 20.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    final zeroY = topPadding + (chartHeight / 2.0); // Baseline in the vertical center

    // Calculate maximum absolute value across income and expense to scale Y
    double maxVal = 0.0;
    for (var pt in dataPoints) {
      if (pt.income > maxVal) maxVal = pt.income;
      if (pt.expense > maxVal) maxVal = pt.expense;
      if (pt.netBalance.abs() > maxVal) maxVal = pt.netBalance.abs();
    }
    if (maxVal <= 0.0) maxVal = 100000.0; // Default scale threshold if zero

    final halfHeight = chartHeight / 2.0;
    final scaleY = halfHeight / maxVal;

    final count = dataPoints.length;
    final stepX = count > 1 ? chartWidth / (count - 1) : chartWidth / 2.0;

    // 1. Draw Background Grid and Zero Baseline
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final zeroLinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.5;

    // Grid lines for +max/2, 0, -max/2
    final topGridY = zeroY - (halfHeight * 0.6);
    final bottomGridY = zeroY + (halfHeight * 0.6);

    canvas.drawLine(Offset(leftPadding, topGridY), Offset(size.width - rightPadding, topGridY), gridPaint);
    canvas.drawLine(Offset(leftPadding, zeroY), Offset(size.width - rightPadding, zeroY), zeroLinePaint);
    canvas.drawLine(Offset(leftPadding, bottomGridY), Offset(size.width - rightPadding, bottomGridY), gridPaint);

    // Y Axis Numerical Labels
    _drawYAxisLabel(canvas, '+${_formatCompactCurrency(maxVal * 0.6)}', Offset(leftPadding - 8, topGridY - 6), AppColors.income);
    _drawYAxisLabel(canvas, 'Rp 0', Offset(leftPadding - 8, zeroY - 6), AppColors.textMuted);
    _drawYAxisLabel(canvas, '-${_formatCompactCurrency(maxVal * 0.6)}', Offset(leftPadding - 8, bottomGridY - 6), AppColors.expense);

    // 2. Draw Bi-Directional Bars: Income (Upward), Expense (Downward)
    final barWidth = math.max(3.0, math.min(18.0, (chartWidth / count) * 0.5));

    final incomeBarPaint = Paint()
      ..color = AppColors.income.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final expenseBarPaint = Paint()
      ..color = AppColors.expense.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final List<Offset> netBalancePoints = [];

    for (int i = 0; i < count; i++) {
      final pt = dataPoints[i];
      final x = leftPadding + (i * stepX);

      // Income Bar: Rises Upward from zeroY
      if (pt.income > 0) {
        final barHeight = pt.income * scaleY;
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - (barWidth / 2.0), zeroY - barHeight, barWidth, barHeight),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rect, incomeBarPaint);
      }

      // Expense Bar: Dips Downward from zeroY
      if (pt.expense > 0) {
        final barHeight = pt.expense * scaleY;
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - (barWidth / 2.0), zeroY, barWidth, barHeight),
          bottomLeft: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        );
        canvas.drawRRect(rect, expenseBarPaint);
      }

      // Net Balance Point
      final netY = zeroY - (pt.netBalance * scaleY);
      netBalancePoints.add(Offset(x, netY));

      // X Axis Label (decimated for readability)
      final shouldDrawXLabel = (count <= 12) || (i % math.max(1, (count / 6).round()) == 0) || (i == count - 1);
      if (shouldDrawXLabel) {
        _drawXAxisLabel(canvas, pt.label, Offset(x, size.height - bottomPadding + 8));
      }
    }

    // 3. Draw Net Balance Trend Line
    if (netBalancePoints.length > 1) {
      final linePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(netBalancePoints[0].dx, netBalancePoints[0].dy);
      for (int i = 1; i < netBalancePoints.length; i++) {
        path.lineTo(netBalancePoints[i].dx, netBalancePoints[i].dy);
      }
      canvas.drawPath(path, linePaint);

      // Circular dots on Net points
      final dotFillPaint = Paint()..color = Colors.white;
      final dotStrokePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (var pt in netBalancePoints) {
        canvas.drawCircle(pt, 3.5, dotFillPaint);
        canvas.drawCircle(pt, 3.5, dotStrokePaint);
      }
    }

    // 4. Draw Interactive Dashed Cursor Line (Matching Google AI Studio Screenshot)
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < count) {
      final hoverX = leftPadding + (hoveredIndex! * stepX);

      final dashedPaint = Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      const dashHeight = 4.0;
      const dashSpace = 4.0;
      double startY = topPadding;

      while (startY < size.height - bottomPadding) {
        canvas.drawLine(
          Offset(hoverX, startY),
          Offset(hoverX, startY + dashHeight),
          dashedPaint,
        );
        startY += dashHeight + dashSpace;
      }

      // Highlight active Net point on hover
      if (hoveredIndex! < netBalancePoints.length) {
        final activeNetPos = netBalancePoints[hoveredIndex!];
        final glowPaint = Paint()
          ..color = AppColors.primary.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(activeNetPos, 8.0, glowPaint);
        canvas.drawCircle(activeNetPos, 4.5, Paint()..color = AppColors.primary);
      }
    }
  }

  void _drawYAxisLabel(Canvas canvas, String text, Offset offset, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width, offset.dy));
  }

  void _drawXAxisLabel(Canvas canvas, String text, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - (textPainter.width / 2.0), offset.dy));
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant _BiDirectionalCashflowPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.hoverPosition != hoverPosition ||
        oldDelegate.dataPoints != dataPoints;
  }
}
