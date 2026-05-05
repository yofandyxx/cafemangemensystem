import 'package:flutter_test/flutter_test.dart';

import 'package:cafemangemensystem/main.dart';

void main() {
  testWidgets('shows the cafe management main menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('CSM - Cafe Management'), findsOneWidget);
    expect(find.text('Menu Utama'), findsOneWidget);
    expect(find.text('Kasir (POS)'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Laporan'), findsOneWidget);
  });
}
