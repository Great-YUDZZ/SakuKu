import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/animated_page_transition.dart';
import '../../../../core/widgets/glass_neumorphic_badge.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../domain/models/financial_health_ratio.dart';
import '../../transactions/views/transaction_form_modal.dart';
import '../view_models/dashboard_view_model.dart';
import 'category_pie_chart.dart';
import 'financial_cashflow_chart.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardView({
    super.key,
    required this.onNavigateToTransactions,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.loadDashboard();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.summary == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final summary = _viewModel.summary;
    final ratio = _viewModel.healthRatio;
    final totalIncome = summary?.totalIncome ?? 0.0;
    final totalExpense = summary?.totalExpense ?? 0.0;
    final balance = summary?.balance ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => TransactionFormModal.show(
          context,
          onSaved: () => _viewModel.loadDashboard(),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Catat Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Month Navigator (matching IT-Toolbox title bar)
              EntranceFader(
                offset: const Offset(0, -10),
                child: _buildHeader(context),
              ),
              const SizedBox(height: 16),

              // StatCards 2x2 Grid (matching the 4 result cards in IT-Toolbox screenshot)
              EntranceFader(
                delay: const Duration(milliseconds: 60),
                child: _buildStatCardsGrid(
                  balance: balance,
                  income: totalIncome,
                  expense: totalExpense,
                  ratio: ratio,
                ),
              ),
              const SizedBox(height: 16),

              // Recommendation Banner (matching "Saran Alokasi..." banner in IT-Toolbox screenshot)
              EntranceFader(
                delay: const Duration(milliseconds: 100),
                child: _buildRecommendationBanner(ratio),
              ),
              const SizedBox(height: 18),

              // FR-02: Health Ratio Details Card
              EntranceFader(
                delay: const Duration(milliseconds: 140),
                child: _buildHealthRatioCard(ratio),
              ),
              const SizedBox(height: 18),

              // Grafik Arus Kas Finansial (Bi-directional Chart: Naik Pemasukan, Turun Pengeluaran)
              EntranceFader(
                delay: const Duration(milliseconds: 160),
                child: FinancialCashflowChart(
                  selectedMonth: _viewModel.selectedMonth,
                ),
              ),
              const SizedBox(height: 18),

              // Category Breakdown & Recent Transactions Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 760;
                  final categorySection = CategoryPieChart(summary: summary);
                  final recentSection = _buildRecentTransactions();

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: EntranceFader(
                            delay: const Duration(milliseconds: 180),
                            child: categorySection,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: EntranceFader(
                            delay: const Duration(milliseconds: 220),
                            child: recentSection,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      EntranceFader(
                        delay: const Duration(milliseconds: 180),
                        child: categorySection,
                      ),
                      const SizedBox(height: 16),
                      EntranceFader(
                        delay: const Duration(milliseconds: 220),
                        child: recentSection,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 80), // FAB clearance
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER BAR ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dasbor & Ringkasan Finansial',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Alat praktis untuk analisis arus kas, rasio kesehatan finansial, dan tabungan lokal.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right side: Category badge & Month selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const GlassNeumorphicBadge(
              label: 'LOCAL & OFFLINE',
              icon: Icons.shield_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            // Month Selector
            GlassNeumorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              borderRadius: AppDimensions.radiusButton,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => _viewModel.previousMonth(),
                    tooltip: 'Bulan Sebelumnya',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      DateFormatter.formatMonthYear(_viewModel.selectedMonth),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => _viewModel.nextMonth(),
                    tooltip: 'Bulan Selanjutnya',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STAT CARDS GRID (Signature IT-Toolbox 2x2 Layout with Left Stripes) ---
  Widget _buildStatCardsGrid({
    required double balance,
    required double income,
    required double expense,
    required FinancialHealthRatio? ratio,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        final cardNetBalance = _buildSignatureStatCard(
          stripeColor: AppColors.primary,
          title: 'TOTAL SALDO BERSIH BULAN INI',
          value: CurrencyFormatter.format(balance),
          valueColor: balance >= 0 ? AppColors.primary : AppColors.expense,
          subtitle: balance >= 0
              ? 'Surplus Arus Kas Tersimpan'
              : 'Defisit Terjadi pada Periode Ini',
        );

        final cardHealth = _buildSignatureStatCard(
          stripeColor: AppColors.income,
          title: 'KESEHATAN FINANSIAL (FR-02)',
          value: ratio != null
              ? '${ratio.status.label} (${(ratio.savingsRatio ?? 0).toStringAsFixed(0)}% Tabungan)'
              : 'Belum Terkalkulasi',
          valueColor: ratio != null ? ratio.status.color : AppColors.income,
          subtitle: ratio != null
              ? 'Rasio tabungan & batas pengeluaran aman'
              : 'Catat transaksi untuk melihat status',
        );

        final cardIncome = _buildSignatureStatCard(
          stripeColor: AppColors.warning,
          title: 'TOTAL PEMASUKAN',
          value: CurrencyFormatter.format(income),
          valueColor: AppColors.warning,
          subtitle: 'Akumulasi seluruh sumber dana masuk',
        );

        final cardExpense = _buildSignatureStatCard(
          stripeColor: AppColors.expense,
          title: 'TOTAL PENGELUARAN',
          value: CurrencyFormatter.format(expense),
          valueColor: AppColors.expense,
          subtitle: 'Pengeluaran kebutuhan & gaya hidup',
        );

        if (isWide) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cardNetBalance),
                  const SizedBox(width: 14),
                  Expanded(child: cardHealth),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: cardIncome),
                  const SizedBox(width: 14),
                  Expanded(child: cardExpense),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            cardNetBalance,
            const SizedBox(height: 12),
            cardHealth,
            const SizedBox(height: 12),
            cardIncome,
            const SizedBox(height: 12),
            cardExpense,
          ],
        );
      },
    );
  }

  Widget _buildSignatureStatCard({
    required Color stripeColor,
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
  }) {
    return GlassNeumorphicCard(
      stripeColor: stripeColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: AppDimensions.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- RECOMMENDATION BANNER (matching IT-Toolbox "Saran Alokasi..." banner) ---
  Widget _buildRecommendationBanner(FinancialHealthRatio? ratio) {
    final recommendation = ratio?.recommendation ??
        'Alokasikan pendapatan menggunakan rumus 50/30/20: 50% Kebutuhan pokok, 30% Keinginan, 20% Tabungan & Investasi.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neuInsetLight,
            offset: Offset(-1, -1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: AppColors.neuInsetDark,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'Saran Alokasi Finansial: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: recommendation,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HEALTH RATIO DETAILS (FR-02) ---
  Widget _buildHealthRatioCard(FinancialHealthRatio? ratio) {
    if (ratio == null) return const SizedBox.shrink();

    final savingsPct = ratio.savingsRatio;
    final expensePct = ratio.expenseToIncomeRatio;
    final status = ratio.status;

    return GlassNeumorphicCard(
      stripeColor: status.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(status.icon, color: status.color, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Evaluasi Rasio Kesehatan Ekonomi (FR-02)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GlassNeumorphicBadge(
                label: status.label,
                color: status.color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ratio.statusDescription,
            style: TextStyle(
              color: status.color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          // Savings Ratio Progress
          _buildRatioBar(
            title: 'Savings Ratio (Target Standar Sehat ≥ 20%)',
            percentage: savingsPct,
            targetPercentage: 20.0,
            isSavings: true,
            activeColor: (savingsPct != null && savingsPct >= 20.0)
                ? AppColors.income
                : ((savingsPct != null && savingsPct >= 10.0)
                    ? AppColors.warning
                    : AppColors.expense),
          ),
          const SizedBox(height: 12),

          // Expense-to-Income Progress
          _buildRatioBar(
            title: 'Expense-to-Income (Batas Aman Terkendali ≤ 80%)',
            percentage: expensePct,
            targetPercentage: 80.0,
            isSavings: false,
            activeColor: (expensePct != null && expensePct <= 80.0)
                ? AppColors.income
                : AppColors.expense,
          ),
        ],
      ),
    );
  }

  Widget _buildRatioBar({
    required String title,
    required double? percentage,
    required double targetPercentage,
    required bool isSavings,
    required Color activeColor,
  }) {
    final hasValue = percentage != null;
    final clampedRatio = hasValue
        ? (percentage.clamp(0.0, 100.0) / 100.0)
        : 0.0;
    final displayPct = hasValue ? '${percentage.toStringAsFixed(1)}%' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayPct,
              style: TextStyle(
                color: activeColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedRatio,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }



  // --- RECENT TRANSACTIONS ---
  Widget _buildRecentTransactions() {
    final recent = _viewModel.recentTransactions;

    return GlassNeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Transaksi Terkini',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onNavigateToTransactions,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (recent.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Belum ada transaksi di bulan ini',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
          ] else ...[
            ...recent.take(5).map((item) {
              final isIncome = item.isIncome;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.category.color.withOpacity(0.12),
                        border: Border.all(
                          color: item.category.color.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(item.category.icon,
                          size: 15, color: item.category.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DateFormatter.formatRelative(item.date),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? "+" : "-"} ${CurrencyFormatter.format(item.amount)}',
                      style: TextStyle(
                        color: isIncome ? AppColors.income : AppColors.expense,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
