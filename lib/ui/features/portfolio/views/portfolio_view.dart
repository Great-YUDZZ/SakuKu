import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/animated_page_transition.dart';
import '../../../../core/widgets/glass_neumorphic_badge.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../../../../domain/models/debt_entity.dart';
import '../../../../domain/models/investment_entity.dart';
import '../../../../domain/services/financial_calculator_service.dart';
import '../view_models/portfolio_view_model.dart';
import 'debt_form_modal.dart';
import 'investment_form_modal.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  late final PortfolioViewModel _viewModel;
  final FinancialCalculatorService _calculatorService = const FinancialCalculatorService();

  // Calculator State
  double _calcLoanPrincipal = 50000000;
  double _calcLoanRate = 8.5;
  int _calcLoanTenor = 24;
  bool _calcIsAnnuity = false;

  double _calcInvestInitial = 10000000;
  double _calcInvestMonthly = 1500000;
  double _calcInvestReturn = 12.0;
  int _calcInvestYears = 5;

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioViewModel();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusModal)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Jenis Catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.primary),
              ),
              title: const Text('Instrumen Investasi', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Saham, Reksadana, Crypto, SBN, Emas, Deposito', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(ctx).pop();
                InvestmentFormModal.show(
                  context,
                  onSaved: (inv) => _viewModel.addInvestment(inv),
                );
              },
            ),
            const Divider(color: AppColors.borderSubtle),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.expense),
              ),
              title: const Text('Hutang atau Piutang', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Pinjaman bank, KPR, hutang pribadi, atau piutang', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(ctx).pop();
                DebtFormModal.show(
                  context,
                  onSaved: (debt) => _viewModel.addDebt(debt),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRepayDialog(DebtEntity debt) {
    final repayController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text(
          debt.type == DebtType.debt ? 'Bayar Cicilan Hutang' : 'Terima Pembayaran Piutang',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pinjaman: ${debt.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Sisa Belum Lunas: ${CurrencyFormatter.format(debt.remainingAmount)}',
              style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            GlassNeumorphicInput(
              controller: repayController,
              labelText: 'Nominal Pembayaran (Rp)',
              hintText: '0',
              prefixIcon: const Icon(Icons.payments_outlined),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final numVal = CurrencyFormatter.parse(val);
                repayController.value = TextEditingValue(
                  text: CurrencyFormatter.format(numVal),
                  selection: TextSelection.collapsed(
                    offset: CurrencyFormatter.format(numVal).length,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final amount = CurrencyFormatter.parse(repayController.text);
              if (amount > 0) {
                _viewModel.recordRepayment(debt.id!, amount);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceDialog(InvestmentEntity inv) {
    final priceController = TextEditingController(text: CurrencyFormatter.format(inv.currentValue));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Pembaruan Nilai: ${inv.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${inv.platform} • Modal: ${CurrencyFormatter.format(inv.investedAmount)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            GlassNeumorphicInput(
              controller: priceController,
              labelText: 'Nilai Pasar Terkini (Rp)',
              hintText: '0',
              prefixIcon: const Icon(Icons.show_chart_rounded),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final numVal = CurrencyFormatter.parse(val);
                priceController.value = TextEditingValue(
                  text: CurrencyFormatter.format(numVal),
                  selection: TextSelection.collapsed(
                    offset: CurrencyFormatter.format(numVal).length,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newPrice = CurrencyFormatter.parse(priceController.text);
              if (newPrice >= 0) {
                _viewModel.updateInvestmentCurrentValue(inv.id!, newPrice);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Simpan Nilai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.summary == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final summary = _viewModel.summary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Aset / Hutang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
              // Header
              EntranceFader(
                offset: const Offset(0, -10),
                child: _buildHeader(),
              ),
              const SizedBox(height: 16),

              // 4 Signature StatCards with Accent Stripe (Cobalt, Coral, Emerald, Amber)
              EntranceFader(
                delay: const Duration(milliseconds: 60),
                child: _buildStatCardsGrid(summary),
              ),
              const SizedBox(height: 18),

              // Main Tabs Selector: Investasi, Hutang & Piutang, Kalkulator
              EntranceFader(
                delay: const Duration(milliseconds: 100),
                child: _buildMainTabs(),
              ),
              const SizedBox(height: 16),

              // Tab View Content
              EntranceFader(
                delay: const Duration(milliseconds: 140),
                child: _buildActiveTabContent(),
              ),

              const SizedBox(height: 80), // FAB clearance
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portofolio & Pengelola Hutang',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pantau aset saham, reksadana, crypto, kewajiban hutang, kalkulator bunga, dan tenggat waktu.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        GlassNeumorphicBadge(
          label: 'WORKBENCH',
          icon: Icons.monetization_on_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCardsGrid(PortfolioSummary? summary) {
    final totalInvest = summary?.totalCurrentValue ?? 0.0;
    final totalDebt = summary?.totalActiveDebt ?? 0.0;
    final netWorth = summary?.netWorth ?? 0.0;
    final dueSoon = summary?.dueSoonCount ?? 0;
    final overdue = summary?.overdueCount ?? 0;
    final pnl = summary?.totalUnrealizedPnL ?? 0.0;
    final pnlPct = summary?.returnPercentage ?? 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        final card1 = GlassNeumorphicCard(
          stripeColor: AppColors.primary,
          child: _buildStatCardItem(
            label: 'TOTAL ASET INVESTASI',
            value: CurrencyFormatter.format(totalInvest),
            valueColor: AppColors.primary,
            subtitle: 'PnL: ${pnl >= 0 ? '+' : ''}${CurrencyFormatter.format(pnl)} (${pnlPct.toStringAsFixed(1)}%)',
            subtitleColor: pnl >= 0 ? AppColors.income : AppColors.expense,
            icon: Icons.trending_up_rounded,
          ),
        );

        final card2 = GlassNeumorphicCard(
          stripeColor: AppColors.expense,
          child: _buildStatCardItem(
            label: 'TOTAL HUTANG BERJALAN',
            value: CurrencyFormatter.format(totalDebt),
            valueColor: AppColors.expense,
            subtitle: '${summary?.activeDebtCount ?? 0} pinjaman aktif',
            subtitleColor: AppColors.textMuted,
            icon: Icons.receipt_long_rounded,
          ),
        );

        final card3 = GlassNeumorphicCard(
          stripeColor: AppColors.income,
          child: _buildStatCardItem(
            label: 'KEKAYAAN BERSIH (NET WORTH)',
            value: CurrencyFormatter.format(netWorth),
            valueColor: netWorth >= 0 ? AppColors.income : AppColors.expense,
            subtitle: 'Aset Investasi dikurangi Total Hutang',
            subtitleColor: AppColors.textMuted,
            icon: Icons.account_balance_wallet_rounded,
          ),
        );

        final card4 = GlassNeumorphicCard(
          stripeColor: overdue > 0 ? AppColors.expense : AppColors.warning,
          child: _buildStatCardItem(
            label: 'STATUS JATUH TEMPO (DUE ALERT)',
            value: overdue > 0 ? '$overdue LEWAT TEMPO' : (dueSoon > 0 ? '$dueSoon SEGERA TEMPO' : 'SEMUA AMAN'),
            valueColor: overdue > 0 ? AppColors.expense : (dueSoon > 0 ? AppColors.warning : AppColors.income),
            subtitle: overdue > 0 ? 'Perlu tindakan segera!' : '≤ 7 hari: $dueSoon pinjaman',
            subtitleColor: AppColors.textMuted,
            icon: Icons.alarm_rounded,
          ),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 12),
              Expanded(child: card2),
              const SizedBox(width: 12),
              Expanded(child: card3),
              const SizedBox(width: 12),
              Expanded(child: card4),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: card3),
                const SizedBox(width: 12),
                Expanded(child: card4),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCardItem({
    required String label,
    required String value,
    required Color valueColor,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            Icon(icon, size: 16, color: valueColor),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMainTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              index: 0,
              label: 'Portofolio Investasi',
              icon: Icons.trending_up_rounded,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              index: 1,
              label: 'Hutang & Piutang',
              icon: Icons.receipt_long_rounded,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              index: 2,
              label: 'Kalkulator Bunga',
              icon: Icons.calculate_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _viewModel.currentTabIndex == index;
    return GestureDetector(
      onTap: () => _viewModel.setTabIndex(index),
      child: AnimatedContainer(
        duration: AppDimensions.durationMicro,
        padding: const EdgeInsets.symmetric(vertical: 9),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_viewModel.currentTabIndex) {
      case 0:
        return _buildInvestmentsSection();
      case 1:
        return _buildDebtsSection();
      case 2:
        return _buildCalculatorSection();
      default:
        return _buildInvestmentsSection();
    }
  }

  // ==========================================
  // TAB 1: INVESTMENTS VIEW
  // ==========================================
  Widget _buildInvestmentsSection() {
    final investments = _viewModel.filteredInvestments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(null, 'Semua Kategori'),
              ...InvestmentCategory.values.map(
                (c) => _buildCategoryChip(c, c.label),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (investments.isEmpty)
          _buildEmptyCard(
            title: 'Belum ada aset investasi',
            subtitle: 'Tekan "+ Tambah Aset / Hutang" untuk mencatat saham, crypto, reksadana, atau deposito Anda.',
            icon: Icons.show_chart_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: investments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final inv = investments[index];
              return _buildInvestmentCard(inv);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryChip(InvestmentCategory? category, String label) {
    final isSelected = _viewModel.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        backgroundColor: AppColors.cardSurface,
        selectedColor: AppColors.primaryTint,
        checkmarkColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        onSelected: (_) => _viewModel.setInvestmentCategory(category),
      ),
    );
  }

  Widget _buildInvestmentCard(InvestmentEntity inv) {
    final pnl = inv.profitOrLoss;
    final pnlPct = inv.returnPercentage;
    final isProfit = inv.isProfitable;
    final pnlColor = isProfit ? AppColors.income : AppColors.expense;

    return GlassNeumorphicCard(
      stripeColor: inv.category.color,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: inv.category.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(inv.category.icon, size: 18, color: inv.category.color),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${inv.category.label} • Platform: ${inv.platform}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              // PnL Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pnlColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      color: pnlColor,
                      size: 20,
                    ),
                    Text(
                      '${isProfit ? "+" : ""}${pnlPct.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: pnlColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 10),

          // Values: Modal Disetor vs Nilai Terkini vs PnL Nominal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modal Pokok', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(CurrencyFormatter.format(inv.investedAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Nilai Pasar Terkini', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(inv.currentValue),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Untung / Rugi (PnL)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    '${isProfit ? "+" : ""}${CurrencyFormatter.format(pnl)}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: pnlColor),
                  ),
                ],
              ),
            ],
          ),

          if (inv.maturityDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardInner,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_available_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Jatuh Tempo: ${DateFormatter.formatShort(inv.maturityDate!)}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    inv.daysToMaturity != null
                        ? (inv.daysToMaturity! >= 0 ? '${inv.daysToMaturity} hari lagi' : 'Telah jatuh tempo')
                        : '',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showUpdatePriceDialog(inv),
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Update Nilai', style: TextStyle(fontSize: 12)),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                onPressed: () => InvestmentFormModal.show(
                  context,
                  initialInvestment: inv,
                  onSaved: (updated) => _viewModel.updateInvestment(updated),
                ),
                tooltip: 'Edit Aset',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                onPressed: () => _viewModel.deleteInvestment(inv.id!),
                tooltip: 'Hapus Aset',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: DEBTS VIEW
  // ==========================================
  Widget _buildDebtsSection() {
    final debts = _viewModel.filteredDebts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Debt / Receivable Switcher
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardInner,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: AppColors.borderMedium, width: 1.0),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              Expanded(
                child: _buildDebtSubToggle(
                  type: DebtType.debt,
                  label: 'Hutang Saya (Liabilitas)',
                  icon: Icons.arrow_circle_down_rounded,
                  activeColor: AppColors.expense,
                ),
              ),
              Expanded(
                child: _buildDebtSubToggle(
                  type: DebtType.receivable,
                  label: 'Piutang Orang Lain',
                  icon: Icons.arrow_circle_up_rounded,
                  activeColor: AppColors.income,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (debts.isEmpty)
          _buildEmptyCard(
            title: 'Tidak ada data ${_viewModel.selectedDebtType.label.toLowerCase()}',
            subtitle: 'Tekan "+ Tambah Aset / Hutang" untuk mencatat hutang atau piutang baru.',
            icon: Icons.receipt_long_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: debts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final d = debts[index];
              return _buildDebtCard(d);
            },
          ),
      ],
    );
  }

  Widget _buildDebtSubToggle({
    required DebtType type,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _viewModel.selectedDebtType == type;
    return GestureDetector(
      onTap: () => _viewModel.setDebtType(type),
      child: AnimatedContainer(
        duration: AppDimensions.durationMicro,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton - 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCard(DebtEntity debt) {
    final isPaid = debt.isPaid;
    final urgency = _calculatorService.calculateDueUrgency(
      daysRemaining: debt.daysRemaining,
      isPaid: isPaid,
    );

    return GlassNeumorphicCard(
      stripeColor: urgency.color,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pihak: ${debt.personOrInstitution} • ${debt.interestType.label}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Urgency Badge (Due Alert)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgency.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(urgency.icon, size: 14, color: urgency.color),
                    const SizedBox(width: 5),
                    Text(
                      urgency.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: urgency.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar Pelunasan
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (debt.paidPercentage / 100.0).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isPaid ? AppColors.income : AppColors.primary,
              ),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),

          // Nominal Pokok vs Sisa vs Bunga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pokok Pinjaman', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(CurrencyFormatter.format(debt.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Sisa Belum Lunas', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(debt.remainingAmount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isPaid ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Suku Bunga', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    debt.interestRate > 0 ? '${debt.interestRate}%/thn' : '0% (Bebas)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Jatuh Tempo & Days Remaining
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardInner,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 13, color: urgency.color),
                    const SizedBox(width: 6),
                    Text(
                      'Jatuh Tempo: ${DateFormatter.formatShort(debt.dueDate)}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  isPaid
                      ? 'Lunas'
                      : (debt.daysRemaining >= 0
                          ? '${debt.daysRemaining} hari lagi'
                          : 'Terlambat ${debt.daysRemaining.abs()} hari'),
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: urgency.color),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Actions: Bayar Cicilan, Edit, Hapus
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isPaid)
                ElevatedButton.icon(
                  onPressed: () => _showRepayDialog(debt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 14, color: Colors.white),
                  label: Text(
                    debt.type == DebtType.debt ? 'Bayar Cicilan' : 'Terima Pembayaran',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                onPressed: () => DebtFormModal.show(
                  context,
                  initialDebt: debt,
                  onSaved: (updated) => _viewModel.updateDebt(updated),
                ),
                tooltip: 'Edit Pinjaman',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                onPressed: () => _viewModel.deleteDebt(debt.id!),
                tooltip: 'Hapus Pinjaman',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: FINANCIAL CALCULATOR (BUNGA & INVESTASI)
  // ==========================================
  Widget _buildCalculatorSection() {
    final loanResult = _calcIsAnnuity
        ? _calculatorService.calculateEffectiveAnnuity(
            principal: _calcLoanPrincipal,
            annualInterestRate: _calcLoanRate,
            tenorMonths: _calcLoanTenor,
          )
        : _calculatorService.calculateFlatLoan(
            principal: _calcLoanPrincipal,
            annualInterestRate: _calcLoanRate,
            tenorMonths: _calcLoanTenor,
          );

    final compoundResult = _calculatorService.calculateCompoundGrowth(
      initialDeposit: _calcInvestInitial,
      monthlyContribution: _calcInvestMonthly,
      annualReturnRate: _calcInvestReturn,
      years: _calcInvestYears,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-calculator 1: Loan & Interest Calculator
        GlassNeumorphicCard(
          stripeColor: AppColors.expense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate_outlined, color: AppColors.expense, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Penghitung Bunga Pinjaman / Cicilan',
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  // Method Switcher: Flat vs Anuitas
                  Row(
                    children: [
                      Text(
                        _calcIsAnnuity ? 'Bunga Anuitas' : 'Bunga Flat',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      Switch(
                        value: _calcIsAnnuity,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _calcIsAnnuity = val),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Inputs Sliders / Values
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pokok Pinjaman: ${CurrencyFormatter.format(_calcLoanPrincipal)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcLoanPrincipal,
                          min: 1000000,
                          max: 500000000,
                          divisions: 100,
                          activeColor: AppColors.expense,
                          onChanged: (val) => setState(() => _calcLoanPrincipal = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suku Bunga: ${_calcLoanRate.toStringAsFixed(1)}% per tahun', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcLoanRate,
                          min: 0,
                          max: 30,
                          divisions: 60,
                          activeColor: AppColors.warning,
                          onChanged: (val) => setState(() => _calcLoanRate = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenor: $_calcLoanTenor Bulan (${(_calcLoanTenor / 12).toStringAsFixed(1)} thn)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcLoanTenor.toDouble(),
                          min: 6,
                          max: 120,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _calcLoanTenor = val.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Calculation Result Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: AppColors.borderMedium, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Angsuran per Bulan', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(loanResult.monthlyInstallment),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.expense),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Total Bunga Terbayar', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(loanResult.totalInterest),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.warning),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(loanResult.totalPayment),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Sub-calculator 2: Compound Interest Investment Projection (DCA)
        GlassNeumorphicCard(
          stripeColor: AppColors.income,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: AppColors.income, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kalkulator Bunga Majemuk & Proyeksi Investasi (DCA)',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Modal Awal: ${CurrencyFormatter.format(_calcInvestInitial)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcInvestInitial,
                          min: 0,
                          max: 100000000,
                          divisions: 100,
                          activeColor: AppColors.income,
                          onChanged: (val) => setState(() => _calcInvestInitial = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Investasi Rutin Bulanan: ${CurrencyFormatter.format(_calcInvestMonthly)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcInvestMonthly,
                          min: 0,
                          max: 20000000,
                          divisions: 40,
                          activeColor: AppColors.cyan,
                          onChanged: (val) => setState(() => _calcInvestMonthly = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ekspektasi Return Tahunan: ${_calcInvestReturn.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcInvestReturn,
                          min: 1,
                          max: 30,
                          divisions: 58,
                          activeColor: AppColors.income,
                          onChanged: (val) => setState(() => _calcInvestReturn = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jangka Waktu: $_calcInvestYears Tahun', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Slider(
                          value: _calcInvestYears.toDouble(),
                          min: 1,
                          max: 25,
                          divisions: 24,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _calcInvestYears = val.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Compound Result Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: AppColors.borderMedium, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimasi Nilai Akhir Portofolio', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(compoundResult.futureValue),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.income),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Total Modal Disetor', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(compoundResult.totalInvested),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Keuntungan Bunga Majemuk', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '+${CurrencyFormatter.format(compoundResult.totalEarnings)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.income),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
