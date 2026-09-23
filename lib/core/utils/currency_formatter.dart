import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  /// Format angka nominal ke format Rupiah standar, misal: "Rp 150.000"
  static String format(double amount, {bool includeSymbol = true}) {
    if (!includeSymbol) {
      return NumberFormat.decimalPattern('id_ID').format(amount);
    }
    return _formatter.format(amount);
  }

  /// Format ringkas untuk visual grafis / card sempit, misal: "Rp 1,5 jt"
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  /// Format dengan tanda positif / negatif eksplisit
  static String formatSigned(double amount, {bool isIncome = true}) {
    final prefix = isIncome ? '+ ' : '- ';
    final absAmount = amount.abs();
    return '$prefix${_formatter.format(absAmount)}';
  }

  /// Parse string input nominal dengan toleransi terhadap separator titik atau koma
  /// Contoh valid:
  /// - "150000" -> 150000.0
  /// - "150.000" -> 150000.0
  /// - "150,000" -> 150000.0
  /// - "150.000,50" -> 150000.5
  /// - "Rp 150.000" -> 150000.0
  static double parse(String input) {
    if (input.trim().isEmpty) return 0.0;

    // Bersihkan karakter non-angka kecuali titik dan koma
    String cleaned = input.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    if (cleaned.isEmpty) return 0.0;

    // Jika memiliki kedua tanda '.' dan ',' (misal 150.000,00 atau 150,000.00)
    if (cleaned.contains('.') && cleaned.contains(',')) {
      final lastDot = cleaned.lastIndexOf('.');
      final lastComma = cleaned.lastIndexOf(',');
      if (lastComma > lastDot) {
        // Format Indonesia/Eropa: 150.000,50
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Format US: 150,000.50
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains('.')) {
      // Cek apakah titik merupakan pemisah ribuan (3 digit di belakang) atau desimal
      final parts = cleaned.split('.');
      if (parts.length > 2) {
        // Lebih dari satu titik, pasti ribuan: 1.000.000
        cleaned = cleaned.replaceAll('.', '');
      } else if (parts.length == 2 && parts[1].length == 3) {
        // Contoh: 150.000 -> pemisah ribuan
        cleaned = cleaned.replaceAll('.', '');
      }
    } else if (cleaned.contains(',')) {
      // Cek apakah koma merupakan pemisah ribuan
      final parts = cleaned.split(',');
      if (parts.length > 2) {
        cleaned = cleaned.replaceAll(',', '');
      } else if (parts.length == 2 && parts[1].length == 3) {
        cleaned = cleaned.replaceAll(',', '');
      } else {
        // Koma sebagai desimal: 150,5
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    return double.tryParse(cleaned) ?? 0.0;
  }
}
