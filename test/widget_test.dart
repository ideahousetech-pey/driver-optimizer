import 'package:flutter_test/flutter_test.dart';
import 'package:driver_optimizer/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverOptimizerApp());

    expect(find.text('Driver Optimizer'), findsOneWidget);
  });
}