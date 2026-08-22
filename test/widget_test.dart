import 'package:flutter_test/flutter_test.dart';
import 'package:techallocate/main.dart';

void main() {
  testWidgets('Shows Employee ID and PIN login', (WidgetTester tester) async {
    await tester.pumpWidget(const TechAllocateApp());

    expect(find.text('TechAllocate'), findsOneWidget);
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('PIN'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
