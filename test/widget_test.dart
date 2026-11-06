import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mathall/main.dart';
import 'package:mathall/core/providers/settings_provider.dart';
import 'package:mathall/core/providers/history_provider.dart';
import 'package:mathall/core/providers/mastery_provider.dart';
import 'package:mathall/data/local/settings_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsProvider(SettingsRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => HistoryProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => MasteryProvider(prefs),
          ),
        ],
        child: const MathWorkoutApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MathWorkoutApp), findsOneWidget);
  });
}
