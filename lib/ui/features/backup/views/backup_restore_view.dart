import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/animated_page_transition.dart';
import '../../../../core/widgets/glass_neumorphic_badge.dart';
import '../../../../core/widgets/glass_neumorphic_button.dart';
import '../../../../core/widgets/glass_neumorphic_card.dart';
import '../../../../core/widgets/glass_neumorphic_input.dart';
import '../view_models/backup_view_model.dart';

class BackupRestoreView extends StatefulWidget {
  final VoidCallback onDataRestored;

  const BackupRestoreView({super.key, required this.onDataRestored});

  @override
  State<BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<BackupRestoreView> {
  late final BackupViewModel _viewModel;
  final TextEditingController _customPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = BackupViewModel();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.loadAvailableBackups();
  }

  @override
  void dispose() {
    _customPathController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleRestore(String path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(color: AppColors.borderMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Pemulihan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Pemulihan data akan mengganti data transaksi saat ini dengan arsip cadangan:\n\n$path\n\nJika arsip rusak, sistem akan otomatis melakukan rollback tanpa merusak database lama.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 2,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Lanjutkan Restore',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await _viewModel.restoreData(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: res.success ? AppColors.income : AppColors.expense,
            content: Text(
              res.message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
        if (res.success) {
          widget.onDataRestored();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cadangan & Pemulihan (FR-03)',
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
                      'Kelola keamanan data lokal Anda secara mandiri tanpa ketergantungan pihak ketiga',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Zero Telemetry Privacy Card
              EntranceFader(
                delay: const Duration(milliseconds: 60),
                child: GlassNeumorphicCard(
                  stripeColor: AppColors.primary,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prinsip Keamanan & Privasi 100% Offline',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Aplikasi ini tidak memiliki server eksternal, analitik, ataupun pelacak telemetri. File cadangan terenkripsi disimpan langsung di folder lokal perangkat Anda.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Export Backup Card
              EntranceFader(
                delay: const Duration(milliseconds: 120),
                child: GlassNeumorphicCard(
                  stripeColor: AppColors.income,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.file_upload_outlined,
                                  color: AppColors.income, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Ekspor Cadangan Data',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GlassNeumorphicBadge(
                            label: 'SHA-256 Checksum',
                            icon: Icons.verified_user_rounded,
                            color: AppColors.income,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menghasilkan file arsip JSON terenkripsi dengan checksum integritas otomatis. Cocok untuk dipindahkan secara manual antar perangkat (Android, Linux, Windows).',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassNeumorphicButton(
                        variant: ButtonVariant.income,
                        height: 46,
                        onPressed: _viewModel.isProcessing
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final res = await _viewModel.exportData();
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: res.success
                                          ? AppColors.income
                                          : AppColors.expense,
                                      content: Text(
                                        res.message,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: _viewModel.isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_download_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ekspor Cadangan Sekarang'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Restore Backup Card
              EntranceFader(
                delay: const Duration(milliseconds: 180),
                child: GlassNeumorphicCard(
                  stripeColor: AppColors.warning,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings_backup_restore_rounded,
                                  color: AppColors.warning, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Pulihkan dari Cadangan (Restore)',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GlassNeumorphicBadge(
                            label: 'Rollback Protection',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih salah satu file arsip lokal di bawah atau masukkan path file kustom untuk memulihkan seluruh data transaksi:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Manual Path Input
                      Row(
                        children: [
                          Expanded(
                            child: GlassNeumorphicInput(
                              controller: _customPathController,
                              hintText: 'Path file cadangan (.json)...',
                              prefixIcon: const Icon(Icons.folder_open_rounded,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassNeumorphicButton(
                            height: 44,
                            variant: ButtonVariant.primary,
                            onPressed: _viewModel.isProcessing ||
                                    _customPathController.text.trim().isEmpty
                                ? null
                                : () => _handleRestore(
                                    _customPathController.text.trim()),
                            child: const Text('Pulihkan'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of Available Local Backups
                      const Text(
                        'Arsip Cadangan Lokal yang Terdeteksi:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_viewModel.availableBackups.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Belum ada file cadangan yang ditemukan di folder default.',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ] else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _viewModel.availableBackups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final file = _viewModel.availableBackups[index];
                            final fileName = file.uri.pathSegments.last;
                            final fileSize = file.lengthSync();
                            final modified = file.lastModifiedSync();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.cardInner,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusButton),
                                border: Border.all(
                                    color: AppColors.borderMedium, width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.description_rounded,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${(fileSize / 1024).toStringAsFixed(1)} KB • $modified',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _viewModel.isProcessing
                                        ? null
                                        : () => _handleRestore(file.path),
                                    child: const Text(
                                      'Gunakan Ini',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
