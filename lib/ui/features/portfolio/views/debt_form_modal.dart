import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_neumorphic_button.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../../../../domain/models/debt_entity.dart';

class DebtFormModal extends StatefulWidget {
  final DebtEntity? initialDebt;
  final ValueChanged<DebtEntity> onSaved;

  const DebtFormModal({
    super.key,
    this.initialDebt,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    DebtEntity? initialDebt,
    required ValueChanged<DebtEntity> onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DebtFormModal(
        initialDebt: initialDebt,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DebtFormModal> createState() => _DebtFormModalState();
}

class _DebtFormModalState extends State<DebtFormModal> {
  late DebtType _type;
  late InterestType _interestType;
  late DateTime _startDate;
  late DateTime _dueDate;

  late final TextEditingController _titleController;
  late final TextEditingController _personController;
  late final TextEditingController _amountController;
  late final TextEditingController _remainingController;
  late final TextEditingController _interestRateController;
  late final TextEditingController _notesController;

  String? _amountError;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDebt;
    _type = d?.type ?? DebtType.debt;
    _interestType = d?.interestType ?? InterestType.none;
    _startDate = d?.startDate ?? DateTime.now();
    _dueDate = d?.dueDate ?? DateTime.now().add(const Duration(days: 30));

    _titleController = TextEditingController(text: d?.title ?? '');
    _personController = TextEditingController(text: d?.personOrInstitution ?? '');
    _amountController = TextEditingController(
      text: d != null ? CurrencyFormatter.format(d.amount) : '',
    );
    _remainingController = TextEditingController(
      text: d != null ? CurrencyFormatter.format(d.remainingAmount) : '',
    );
    _interestRateController = TextEditingController(
      text: d != null && d.interestRate > 0 ? d.interestRate.toString() : '',
    );
    _notesController = TextEditingController(text: d?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _personController.dispose();
    _amountController.dispose();
    _remainingController.dispose();
    _interestRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Nama pinjaman / pihak wajib diisi');
      return;
    }

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) {
      setState(() => _amountError = 'Nominal harus lebih besar dari 0');
      return;
    }

    final remainingRaw = _remainingController.text.trim();
    final remaining = remainingRaw.isNotEmpty
        ? CurrencyFormatter.parse(remainingRaw).clamp(0.0, amount)
        : amount;

    final rate = double.tryParse(_interestRateController.text.replaceAll(',', '.')) ?? 0.0;

    final entity = DebtEntity(
      id: widget.initialDebt?.id,
      title: title,
      type: _type,
      personOrInstitution: _personController.text.trim().isNotEmpty
          ? _personController.text.trim()
          : (_type == DebtType.debt ? 'Kreditur' : 'Debitur'),
      amount: amount,
      remainingAmount: remaining,
      interestRate: rate,
      interestType: _interestType,
      startDate: _startDate,
      dueDate: _dueDate,
      status: remaining <= 0 ? DebtStatus.paid : DebtStatus.active,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.initialDebt?.createdAt ?? DateTime.now(),
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
              // Modal Grab Handle
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

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialDebt == null ? 'Catat Hutang / Piutang Baru' : 'Edit Catatan Pinjaman',
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

              // Type Selector: Hutang vs Piutang
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: AppColors.borderMedium, width: 1.0),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeToggle(
                        type: DebtType.debt,
                        label: 'Hutang Saya',
                        icon: Icons.arrow_downward_rounded,
                        activeColor: AppColors.expense,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeToggle(
                        type: DebtType.receivable,
                        label: 'Piutang Orang Lain',
                        icon: Icons.arrow_upward_rounded,
                        activeColor: AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Judul / Keterangan
              GlassNeumorphicInput(
                controller: _titleController,
                labelText: 'Nama Hutang / Pinjaman',
                hintText: 'Contoh: KPR Rumah, Pinjaman Modal, Hutang Teman',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                errorText: _titleError,
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
              ),
              const SizedBox(height: 12),

              // Pihak Terkait (Kreditur / Debitur)
              GlassNeumorphicInput(
                controller: _personController,
                labelText: _type == DebtType.debt ? 'Nama Pemberi Pinjaman / Bank' : 'Nama Peminjam',
                hintText: 'Contoh: Bank BCA, Budi, Kredivo',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(height: 12),

              // Nominal Pokok Pinjaman
              GlassNeumorphicInput(
                controller: _amountController,
                labelText: 'Nominal Pokok Pinjaman (Rp)',
                hintText: '0',
                prefixIcon: const Icon(Icons.payments_outlined),
                keyboardType: TextInputType.number,
                errorText: _amountError,
                onChanged: (val) {
                  if (_amountError != null) setState(() => _amountError = null);
                  final numVal = CurrencyFormatter.parse(val);
                  _amountController.value = TextEditingValue(
                    text: CurrencyFormatter.format(numVal),
                    selection: TextSelection.collapsed(
                      offset: CurrencyFormatter.format(numVal).length,
                    ),
                  );
                  if (_remainingController.text.isEmpty) {
                    _remainingController.text = CurrencyFormatter.format(numVal);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Sisa Tagihan (jika sudah dicicil sebagian)
              GlassNeumorphicInput(
                controller: _remainingController,
                labelText: 'Sisa Nominal yang Belum Lunas (Rp)',
                hintText: 'Kosongkan jika sama dengan pokok',
                prefixIcon: const Icon(Icons.pending_actions_rounded),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final numVal = CurrencyFormatter.parse(val);
                  _remainingController.value = TextEditingValue(
                    text: CurrencyFormatter.format(numVal),
                    selection: TextSelection.collapsed(
                      offset: CurrencyFormatter.format(numVal).length,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Bunga & Jenis Bunga
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GlassNeumorphicInput(
                      controller: _interestRateController,
                      labelText: 'Suku Bunga (%/thn)',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.percent_rounded),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Perhitungan Bunga',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cardInner,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                            border: Border.all(color: AppColors.borderMedium, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<InterestType>(
                              value: _interestType,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              items: InterestType.values.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t.label,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _interestType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dates: Tanggal Pinjaman & Tenggat Waktu
              Row(
                children: [
                  Expanded(
                    child: _buildDateTile(
                      label: 'Tanggal Mulai',
                      date: _startDate,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDateTile(
                      label: 'Jatuh Tempo (Due Date)',
                      date: _dueDate,
                      onTap: _pickDueDate,
                      isDue: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Catatan Tambahan
              GlassNeumorphicInput(
                controller: _notesController,
                labelText: 'Catatan Tambahan (Opsional)',
                hintText: 'Nomor rekening, jaminan, kontak, dll.',
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
                          Text('Simpan Pinjaman'),
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

  Widget _buildTypeToggle({
    required DebtType type,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: AppDimensions.durationMicro,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            Icon(icon, size: 14, color: isSelected ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    bool isDue = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDue ? AppColors.expense : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardInner,
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              border: Border.all(
                color: isDue ? AppColors.expense.withOpacity(0.5) : AppColors.borderMedium,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatShort(date),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: isDue ? AppColors.expense : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
