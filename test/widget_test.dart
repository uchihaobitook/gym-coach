import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_coach/app.dart';

void main() {
  testWidgets('GymCoachApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GymCoachApp()),
    );
    // Splash/brand should appear without throwing.
    expect(find.byType(GymCoachApp), findsOneWidget);
  });
}
