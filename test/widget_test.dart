import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    // StorageService depends on SharedPreferences.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
        ],
        child: const LoopsApp(),
      ),
    );

    // Let GoRouter/async providers settle.
    await tester.pumpAndSettle();

    // Verify that the bottom navigation bar icons are present.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
