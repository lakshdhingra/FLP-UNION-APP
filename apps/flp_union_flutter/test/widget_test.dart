import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flp_union_app/main.dart';

void main() {
  testWidgets('App smoke test - mounts successfully', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FlpUnionApp(),
      ),
    );

    // Initial frame renders
    expect(find.byType(FlpUnionApp), findsOneWidget);
  });
}
