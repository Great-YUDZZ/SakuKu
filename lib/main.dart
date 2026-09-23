import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlite3/open.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'ui/adaptive_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SQLite FFI untuk platform desktop (Linux, Windows, macOS)
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so.0');
        } catch (_) {
          return DynamicLibrary.open('libsqlite3.so');
        }
      });
    }
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  }

  runApp(const LocalFinancialManagerApp());
}

class LocalFinancialManagerApp extends StatelessWidget {
  const LocalFinancialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Financial Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      home: const AdaptiveScaffold(),
    );
  }
}
