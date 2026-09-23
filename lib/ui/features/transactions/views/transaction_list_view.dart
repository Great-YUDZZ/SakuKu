import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/animated_page_transition.dart';
import '../../../../core/widgets/glass_neumorphic_badge.dart';
import '../../../../core/widgets/glass_neumorphic_button.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/transaction_entity.dart';
import 'transaction_form_modal.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final TransactionRepository _repository = TransactionRepository();
  final TextEditingController _searchController = TextEditingController();

  List<TransactionEntity> _transactions = [];
  bool _isLoading = true;
  TransactionType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _repository.getAllTransactions(
      type: _selectedFilter,
      searchQuery: _searchController.text,
      limit: 200,
    );
    if (mounted) {
      setState(() {
        _transactions = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(TransactionEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(color: AppColors.borderMedium),
        ),
        title: const Text(
          'Hapus Transaksi?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.description}" (${CurrencyFormatter.format(item.amount)})?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              elevation: 2,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      await _repository.deleteTransaction(item.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => TransactionFormModal.show(context, onSaved: _loadData),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              EntranceFader(
                offset: const Offset(0, -10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daftar mutasi keuangan yang tersimpan di penyimpanan lokal',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Input & Filter Tabs
              EntranceFader(
                delay: const Duration(milliseconds: 60),
                child: Column(
                  children: [
                    GlassNeumorphicInput(
                      controller: _searchController,
                      hintText: 'Cari deskripsi atau kategori...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                _loadData();
                              },
                            )
                          : null,
                      onChanged: (val) => _loadData(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildFilterButton('Semua', null),
                        const SizedBox(width: 8),
                        _buildFilterButton(
                            'Pengeluaran', TransactionType.expense),
                        const SizedBox(width: 8),
                        _buildFilterButton('Pemasukan', TransactionType.income),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction List Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _transactions.isEmpty
                        ? Center(
                            child: EntranceFader(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 56,
                                    color: AppColors.textMuted.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum ada transaksi yang tercatat',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tekan tombol "Catat Transaksi" untuk memulai',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _transactions[index];
                              return EntranceFader(
                                delay: Duration(milliseconds: 25 * (index % 10)),
                                child: _buildTransactionCard(item),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, TransactionType? type) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: GlassNeumorphicButton(
        height: 38,
        isSelected: isSelected,
        variant: type == TransactionType.income
            ? ButtonVariant.income
            : (type == TransactionType.expense
                ? ButtonVariant.expense
                : ButtonVariant.primary),
        onPressed: () {
          setState(() => _selectedFilter = type);
          _loadData();
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionEntity item) {
    final isIncome = item.isIncome;
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    return GlassNeumorphicCard(
      stripeColor: amountColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      borderRadius: AppDimensions.radiusCard,
      child: Row(
        children: [
          // Category Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.category.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.category.color.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Icon(
              item.category.icon,
              color: item.category.color,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),

          // Description and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    GlassNeumorphicBadge(
                      label: item.category.label,
                      color: item.category.color,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatRelative(item.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and Delete Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${CurrencyFormatter.format(item.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _deleteItem(item),
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
