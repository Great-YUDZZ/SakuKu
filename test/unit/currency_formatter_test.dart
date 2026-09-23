import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('Format angka menjadi string Rupiah dengan separator titik', () {
      expect(CurrencyFormatter.format(150000), contains('150.000'));
      expect(CurrencyFormatter.format(1000000), contains('1.000.000'));
    });

    test('Parse input numerik biasa tanpa separator', () {
      expect(CurrencyFormatter.parse('150000'), equals(150000.0));
      expect(CurrencyFormatter.parse('2500000'), equals(2500000.0));
    });

    test('Parse input dengan separator ribuan titik (Indonesian locale)', () {
      expect(CurrencyFormatter.parse('150.000'), equals(150000.0));
      expect(CurrencyFormatter.parse('1.500.000'), equals(1500000.0));
    });

    test('Parse input dengan separator ribuan koma (US locale)', () {
      expect(CurrencyFormatter.parse('150,000'), equals(150000.0));
      expect(CurrencyFormatter.parse('1,500,000'), equals(1500000.0));
    });

    test('Parse input dengan simbol mata uang atau spasi ekstra', () {
      expect(CurrencyFormatter.parse('Rp 250.000'), equals(250000.0));
      expect(CurrencyFormatter.parse('   Rp. 50.000   '), equals(50000.0));
    });

    test('Parse input kosong atau tidak valid menghasilkan 0.0', () {
      expect(CurrencyFormatter.parse(''), equals(0.0));
      expect(CurrencyFormatter.parse('abc'), equals(0.0));
    });
  });
}
