import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doutor_ie/app.dart';
import 'package:doutor_ie/core/providers.dart';

void main() {
  testWidgets('App abre login quando não há token', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DoutorIeApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Iniciar sessão'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
