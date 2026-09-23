import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/core/widgets/glass_neumorphic_badge.dart';
import 'package:local_financial_manager/core/widgets/glass_neumorphic_button.dart';
import 'package:local_financial_manager/core/widgets/glass_neumorphic_card.dart';
import 'package:local_financial_manager/core/widgets/glass_neumorphic_input.dart';

void main() {
  group('Glassmorphism & Neumorphism Widgets', () {
    testWidgets('GlassNeumorphicCard menampilkan konten child dengan benar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassNeumorphicCard(
              child: Text('Konten Kaca'),
            ),
          ),
        ),
      );

      expect(find.text('Konten Kaca'), findsOneWidget);
    });

    testWidgets('GlassNeumorphicButton merespons event klik (onPressed)',
        (tester) async {
      bool clicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassNeumorphicButton(
              onPressed: () => clicked = true,
              child: const Text('Simpan'),
            ),
          ),
        ),
      );

      expect(find.text('Simpan'), findsOneWidget);
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(clicked, isTrue);
    });

    testWidgets('GlassNeumorphicBadge menampilkan label status dengan ikon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassNeumorphicBadge(
              label: 'Sehat',
              icon: Icons.check,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Sehat'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('GlassNeumorphicInput menerima teks input dengan baik',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassNeumorphicInput(
              controller: controller,
              hintText: 'Masukkan nominal',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '150000');
      expect(controller.text, equals('150000'));
    });
  });
}
