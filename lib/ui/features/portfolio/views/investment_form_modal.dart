import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_button.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../../../../domain/models/investment_entity.dart';

class InvestmentFormModal extends StatefulWidget {
  final InvestmentEntity? initialInvestment;
  final ValueChanged<InvestmentEntity> onSaved;

  const InvestmentFormModal({
    super.key,
    this.initialInvestment,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    InvestmentEntity? initialInvestment,
    required ValueChanged<InvestmentEntity> onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvestmentFormModal(
        initialInvestment: initialInvestment,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<InvestmentFormModal> createState() => _InvestmentFormModalState();
}

class _InvestmentFormModalState extends State<InvestmentFormModal> {
  late InvestmentCategory _category;
  late DateTime _startDate;
  DateTime? _maturityDate;

  late final TextEditingController _nameController;
  late final TextEditingController _platformController;
  late final TextEditingController _investedController;
  late final TextEditingController _currentValueController;
  late final TextEditingController _targetController;
  late final TextEditingController _returnRateController;
  late final TextEditingController _notesController;

  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final inv = widget.initialInvestment;
    _category = inv?.category ?? InvestmentCategory.stocks;
    _startDate = inv?.startDate ?? DateTime.now();
    _maturityDate = inv?.maturityDate;

    _nameController = TextEditingController(text: inv?.name ?? '');
    _platformController = TextEditingController(text: inv?.platform ?? '');
    _investedController = TextEditingController(
      text: inv != null ? CurrencyFormatter.format(inv.investedAmount) : '',
    );
    _currentValueController = TextEditingController(
      text: inv != null ? CurrencyFormatter.format(inv.currentValue) : '',
    );
    _targetController = TextEditingController(
      text: (inv?.targetAmount != null && inv!.targetAmount! > 0)
          ? CurrencyFormatter.format(inv.targetAmount!)
          : '',
    );
    _returnRateController = TextEditingController(
      text: inv != null && inv.expectedReturnRate > 0 ? inv.expectedReturnRate.toString() : '',
    );
    _notesController = TextEditingController(text: inv?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _platformController.dispose();
    _investedController.dispose();
    _currentValueController.dispose();
    _targetController.dispose();
    _returnRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickMaturityDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maturityDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );
    if (picked != null) {
      setState(() => _maturityDate = picked);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama aset / kode emiten wajib diisi');
      return;
    }

    final invested = CurrencyFormatter.parse(_investedController.text);
    if (invested <= 0) {
      setState(() => _amountError = 'Modal awal harus lebih dari 0');
      return;
    }

    final currentRaw = _currentValueController.text.trim();
    final currentValue = currentRaw.isNotEmpty ? CurrencyFormatter.parse(currentRaw) : invested;

    final targetRaw = _targetController.text.trim();
    final targetAmount = targetRaw.isNotEmpty ? CurrencyFormatter.parse(targetRaw) : null;

    final returnRate = double.tryParse(_returnRateController.text.replaceAll(',', '.')) ?? 0.0;

    final entity = InvestmentEntity(
      id: widget.initialInvestment?.id,
      name: name,
      category: _category,
      platform: _platformController.text.trim().isNotEmpty
          ? _platformController.text.trim()
          : 'Portofolio Pribadi',
      investedAmount: invested,
      currentValue: currentValue,
      targetAmount: targetAmount,
      expectedReturnRate: returnRate,
      startDate: _startDate,
      maturityDate: _maturityDate,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.initialInvestment?.createdAt ?? DateTime.now(),
    );

    widget.onSaved(entity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusModal)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialInvestment == null ? 'Tambah Aset Investasi Baru' : 'Edit Data Investasi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category Horizontal Selector
              const Text(
                'Kategori Instrumen Investasi',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: InvestmentCategory.values.map((cat) {
                    final isSelected = _category == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: AppDimensions.durationMicro,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? cat.color.withOpacity(0.15) : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                            border: Border.all(
                              color: isSelected ? cat.color : AppColors.borderMedium,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 14, color: isSelected ? cat.color : AppColors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  color: isSelected ? cat.color : AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Nama Aset / Kode Emiten
              GlassNeumorphicInput(
                controller: _nameController,
                labelText: 'Nama Aset / Saham / Koin',
                hintText: 'Contoh: BBCA, Bitcoin, Sucorinvest Equity, ORI024',
                prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 12),

              // Platform / Broker
              GlassNeumorphicInput(
                controller: _platformController,
                labelText: 'Aplikasi / Platform / Sekuritas',
                hintText: 'Contoh: Bibit, Ajaib, Indodax, Stockbit, Bank BCA',
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),
              const SizedBox(height: 12),

              // Modal Awal & Nilai Pasar Terkini
              Row(
                children: [
                  Expanded(
                    child: GlassNeumorphicInput(
                      controller: _investedController,
                      labelText: 'Modal Awal (Rp)',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.savings_outlined),
                      keyboardType: TextInputType.number,
                      errorText: _amountError,
                      onChanged: (val) {
                        if (_amountError != null) setState(() => _amountError = null);
                        final numVal = CurrencyFormatter.parse(val);
                        _investedController.value = TextEditingValue(
                          text: CurrencyFormatter.format(numVal),
                          selection: TextSelection.collapsed(
                            offset: CurrencyFormatter.format(numVal).length,
                          ),
                        );
                        if (_currentValueController.text.isEmpty) {
                          _currentValueController.text = CurrencyFormatter.format(numVal);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassNeumorphicInput(
                      controller: _currentValueController,
                      labelText: 'Nilai Terkini (Rp)',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.show_chart_rounded),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final numVal = CurrencyFormatter.parse(val);
                        _currentValueController.value = TextEditingValue(
                          text: CurrencyFormatter.format(numVal),
                          selection: TextSelection.collapsed(
                            offset: CurrencyFormatter.format(numVal).length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Target Nilai & Ekspektasi Return
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: GlassNeumorphicInput(
                      controller: _targetController,
                      labelText: 'Target Nilai (Opsional)',
                      hintText: 'Target portofolio',
                      prefixIcon: const Icon(Icons.flag_outlined),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final numVal = CurrencyFormatter.parse(val);
                        _targetController.value = TextEditingValue(
                          text: CurrencyFormatter.format(numVal),
                          selection: TextSelection.collapsed(
                            offset: CurrencyFormatter.format(numVal).length,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: GlassNeumorphicInput(
                      controller: _returnRateController,
                      labelText: 'Estimasi Return (%/thn)',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.percent_rounded),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dates: Tanggal Beli & Tenggat Horizon / Jatuh Tempo
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Mulai Investasi',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickStartDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardInner,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                              border: Border.all(color: AppColors.borderMedium, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormatter.formatShort(_startDate), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jatuh Tempo / Horizon',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                            if (_maturityDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _maturityDate = null),
                                child: const Text('Hapus', style: TextStyle(fontSize: 10, color: AppColors.expense, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickMaturityDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardInner,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                              border: Border.all(color: AppColors.borderMedium, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _maturityDate != null ? DateFormatter.formatShort(_maturityDate!) : 'Bebas / Fleksibel',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _maturityDate != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                                const Icon(Icons.event_available_rounded, size: 16, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Catatan
              GlassNeumorphicInput(
                controller: _notesController,
                labelText: 'Catatan Portofolio (Opsional)',
                hintText: 'Strategi DCA, target exit, dll.',
                prefixIcon: const Icon(Icons.note_alt_outlined),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GlassNeumorphicButton(
                      variant: ButtonVariant.neutral,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Batal'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassNeumorphicButton(
                      variant: ButtonVariant.primary,
                      onPressed: _submit,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Simpan Aset'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
