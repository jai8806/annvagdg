import 'package:flutter_test/flutter_test.dart';
import 'package:annva/main.dart';

void main() {
  testWidgets('Annva app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnnvaApp());

    // Verify the Annva wordmark appears
    expect(find.text('Annva'), findsOneWidget);
    expect(find.text('अन्न'), findsOneWidget);
  });
}
