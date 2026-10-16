import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flp_union_app/main.dart';
import 'package:flp_union_app/shared/widgets/app_animations.dart';

void main() {
  testWidgets('App smoke test - mounts successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FlpUnionApp(),
      ),
    );

    expect(find.byType(FlpUnionApp), findsOneWidget);
  });

  testWidgets(
      'AnimatedBranchContainer preserves state and animates between tabs',
      (WidgetTester tester) async {
    int currentIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: AnimatedBranchContainer(
                currentIndex: currentIndex,
                children: const [
                  _TestTabContent(title: 'Dashboard Page', tabIndex: 0),
                  _TestTabContent(title: 'Engineers Page', tabIndex: 1),
                  _TestTabContent(title: 'Managers Page', tabIndex: 2),
                ],
              ),
              bottomNavigationBar: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => currentIndex = 0),
                    child: const Text('Tab 0'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => currentIndex = 1),
                    child: const Text('Tab 1'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Initial state: Tab 0 is visible, Tab 1 is offstage
    expect(find.text('Dashboard Page'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);

    // Tap increment on Tab 0 to verify state preservation
    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('Counter: 1'), findsOneWidget);

    // Switch to Tab 1
    await tester.tap(find.text('Tab 1'));
    // Pump frame to trigger transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));

    // Both tabs are present in widget tree during transition (one incoming, one outgoing)
    expect(find.text('Dashboard Page'), findsOneWidget);
    expect(find.text('Engineers Page'), findsOneWidget);

    // Complete transition
    await tester.pumpAndSettle();

    // Now on Tab 1
    expect(find.text('Engineers Page'), findsOneWidget);

    // Switch back to Tab 0
    await tester.tap(find.text('Tab 0'));
    await tester.pumpAndSettle();

    // Verify Tab 0 restored with EXACT preserved counter value!
    expect(find.text('Dashboard Page'), findsOneWidget);
    expect(find.text('Counter: 1'), findsOneWidget);
  });

  testWidgets(
      'AnimatedBranchContainer direction awareness: left-to-right vs right-to-left',
      (WidgetTester tester) async {
    int currentIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: AnimatedBranchContainer(
                currentIndex: currentIndex,
                children: const [
                  Text('Tab Zero'),
                  Text('Tab One'),
                  Text('Tab Two'),
                ],
              ),
              bottomNavigationBar: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => currentIndex = 0),
                    child: const Text('To 0'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => currentIndex = 2),
                    child: const Text('To 2'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Initial
    expect(find.text('Tab Zero'), findsOneWidget);

    // Forward transition: 0 -> 2 (direction = 1)
    await tester.tap(find.text('To 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));

    // Find FractionalTranslation of incoming widget (Tab Two)
    final incomingFinder = find.descendant(
      of: find.byKey(const ValueKey<int>(2)),
      matching: find.byType(FractionalTranslation),
    );
    expect(incomingFinder, findsOneWidget);
    final incomingTranslation =
        tester.widget<FractionalTranslation>(incomingFinder).translation;
    // Moving forward to the right: incoming slides from positive X towards zero
    expect(incomingTranslation.dx, greaterThan(0.0));

    await tester.pumpAndSettle();
    expect(find.text('Tab Two'), findsOneWidget);

    // Backward transition: 2 -> 0 (direction = -1)
    await tester.tap(find.text('To 0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));

    final backwardIncomingFinder = find.descendant(
      of: find.byKey(const ValueKey<int>(0)),
      matching: find.byType(FractionalTranslation),
    );
    expect(backwardIncomingFinder, findsOneWidget);
    final backwardTranslation = tester
        .widget<FractionalTranslation>(backwardIncomingFinder)
        .translation;
    // Moving backward to the left: incoming slides from negative X towards zero
    expect(backwardTranslation.dx, lessThan(0.0));

    await tester.pumpAndSettle();
    expect(find.text('Tab Zero'), findsOneWidget);
  });

  testWidgets(
      'AnimatedBranchContainer respects reduced motion (disableAnimations)',
      (WidgetTester tester) async {
    int currentIndex = 0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AnimatedBranchContainer(
                  currentIndex: currentIndex,
                  children: const [
                    Text('Static Tab 0'),
                    Text('Static Tab 1'),
                  ],
                ),
                bottomNavigationBar: TextButton(
                  onPressed: () => setState(() => currentIndex = 1),
                  child: const Text('Switch'),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Static Tab 0'), findsOneWidget);

    // Switch tab with reduced motion
    await tester.tap(find.text('Switch'));
    await tester.pump(); // Immediate frame with no transition animation delay

    expect(find.text('Static Tab 1'), findsOneWidget);
  });
}

class _TestTabContent extends StatefulWidget {
  final String title;
  final int tabIndex;

  const _TestTabContent({
    required this.title,
    required this.tabIndex,
  });

  @override
  State<_TestTabContent> createState() => _TestTabContentState();
}

class _TestTabContentState extends State<_TestTabContent> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title),
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
