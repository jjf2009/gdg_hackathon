import 'package:flutter_test/flutter_test.dart';
import 'package:gdg_hackathon/main.dart';

void main() {
  testWidgets('CropDoc app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CropDocApp());
    expect(find.byType(CropDocApp), findsOneWidget);
  });
}
