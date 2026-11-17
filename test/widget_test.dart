import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceNewsExplorerApp(isLoggedIn: false));
    expect(find.byType(SpaceNewsExplorerApp), findsOneWidget);
  });
}
