import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_financial_manager/ui/features/dashboard/views/category_pie_chart.dart';
import 'package:local_financial_manager/ui/features/dashboard/views/financial_statistics_table.dart';

void main() {
  for (final width in [320.0, 360.0, 412.0]) {
    testWidgets('Tidak ada overflow pada lebar $width', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                FinancialStatisticsTable(summary: null),
                CategoryPieChart(summary: null),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
