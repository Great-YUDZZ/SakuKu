import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../data/repositories/backup_repository.dart';

class BackupViewModel extends ChangeNotifier {
  final BackupRepository _repository;

  BackupViewModel({BackupRepository? repository})
      : _repository = repository ?? BackupRepository();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  BackupRestoreResult? _lastResult;
  BackupRestoreResult? get lastResult => _lastResult;

  List<File> _availableBackups = [];
  List<File> get availableBackups => _availableBackups;

  Future<void> loadAvailableBackups() async {
    try {
      final defaultPath = await _repository.getDefaultBackupPath();
      final backupDir = File(defaultPath).parent;
      if (await backupDir.exists()) {
        final files = backupDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList();
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        _availableBackups = files;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading backup files: $e');
      }
    }
  }

  Future<BackupRestoreResult> exportData() async {
    _isProcessing = true;
    _lastResult = null;
    notifyListeners();

    try {
      final result = await _repository.exportBackup();
      _lastResult = result;
      await loadAvailableBackups();
      return result;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<BackupRestoreResult> restoreData(String path) async {
    _isProcessing = true;
    _lastResult = null;
    notifyListeners();

    try {
      final result = await _repository.restoreBackup(path);
      _lastResult = result;
      return result;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
