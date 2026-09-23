import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_button.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../../../../domain/models/transaction_entity.dart';
import '../view_models/transaction_form_view_model.dart';

class TransactionFormModal extends StatefulWidget {
  final VoidCallback onSaved;

  const TransactionFormModal({super.key, required this.onSaved});

  static Future<void> show(BuildContext context, {required VoidCallback onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionFormModal(onSaved: onSaved),
    );
  }

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  late final TransactionFormViewModel _viewModel;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionFormViewModel();
    _amountController = TextEditingController();
    _descController = TextEditingController();

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardSurface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardSurface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _viewModel.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isIncome = _viewModel.type == TransactionType.income;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: GlassNeumorphicCard(
        borderRadius: AppDimensions.radiusModal,
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14.0),
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catat Transaksi Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // Type Toggle Selector (Pengeluaran vs Pemasukan)
              Row(
                children: [
                  Expanded(
                    child: GlassNeumorphicButton(
                      variant: ButtonVariant.expense,
                      isSelected: !isIncome,
                      onPressed: () =>
                          _viewModel.setType(TransactionType.expense),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Pengeluaran'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: GlassNeumorphicButton(
                      variant: ButtonVariant.income,
                      isSelected: isIncome,
                      onPressed: () =>
                          _viewModel.setType(TransactionType.income),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Pemasukan'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18.0),

              // Amount Input Field
              GlassNeumorphicInput(
                controller: _amountController,
                labelText: 'Nominal Transaksi (Rp)',
                hintText: '0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.payments_rounded,
                    color: AppColors.primary),
                onChanged: (val) => _viewModel.setAmountFromInput(val),
              ),
              const SizedBox(height: 14.0),

              // Description Input Field ("Untuk apa")
              GlassNeumorphicInput(
                controller: _descController,
                labelText: 'Tujuan / Keterangan',
                hintText: isIncome
                    ? 'Misal: Gaji Pokok, Freelance Project'
                    : 'Misal: Makan Siang, Bensin, Belanja Bulanan',
                prefixIcon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.primary),
                onChanged: (val) => _viewModel.setDescription(val),
              ),
              const SizedBox(height: 14.0),

              // Date Picker Field
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GlassNeumorphicInput(
                          labelText: 'Tanggal Transaksi',
                          hintText: DateFormatter.formatFull(_viewModel.date),
                          readOnly: true,
                          onTap: _pickDate,
                          prefixIcon: const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // Category Selector
              const Padding(
                padding: EdgeInsets.only(left: 2.0, bottom: 8.0),
                child: Text(
                  'Kategori',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: TransactionCategory.values.map((cat) {
                  final isSelected = _viewModel.category == cat;
                  return GestureDetector(
                    onTap: () => _viewModel.setCategory(cat),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: AppDimensions.durationMicro,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 7.0),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusButton),
                          color: isSelected
                              ? cat.color.withOpacity(0.16)
                              : AppColors.cardInner,
                          border: Border.all(
                            color: isSelected
                                ? cat.color
                                : AppColors.borderMedium,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cat.color.withOpacity(0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: AppColors.neuDarkShadow,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 15,
                              color: isSelected
                                  ? cat.color
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                color: isSelected
                                    ? cat.color
                                    : AppColors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_viewModel.errorMessage != null) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColors.expenseTint,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: AppColors.expense.withOpacity(0.4), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 16, color: AppColors.expense),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _viewModel.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.expense,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22.0),

              // Save Button (FR-01)
              GlassNeumorphicButton(
                variant:
                    isIncome ? ButtonVariant.income : ButtonVariant.expense,
                height: 48.0,
                onPressed: _viewModel.isValid
                    ? () async {
                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await _viewModel.saveTransaction();
                        if (success && mounted) {
                          nav.pop();
                          widget.onSaved();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.textPrimary,
                              content: Text(
                                'Transaksi ${CurrencyFormatter.format(_viewModel.amount)} berhasil dicatat!',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: _viewModel.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan Transaksi ${_viewModel.amount > 0 ? CurrencyFormatter.formatCompact(_viewModel.amount) : ""}',
                            style: const TextStyle(fontSize: 14.5),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
