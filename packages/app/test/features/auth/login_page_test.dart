import 'package:app/features/auth/views/login_page.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

Widget wrap(Preferences preferences) {
  return ProviderScope(
    overrides: [preferenceProvider.overrideWithValue(preferences)],
    child: const MaterialApp(home: LoginPage()),
  );
}

void main() {
  group('LoginPage', () {
    testWidgets('renders an email and a password field', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
    });

    testWidgets('offers a way to reach signup', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(
        find.widgetWithText(
          TextButton,
          "Don't have an account? Create account",
        ),
        findsOneWidget,
      );
    });

    testWidgets('rejects an empty submit without calling the network', (
      tester,
    ) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      expect(preferences.getValue<String?>(PreferenceKeys.accessToken), isNull);
    });

    testWidgets('rejects a malformed email and a short password', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'not-an-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('accepts a well-formed email and password', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'someone@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'correct-horse',
      );
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsNothing);
      expect(find.text('Password must be at least 8 characters'), findsNothing);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
