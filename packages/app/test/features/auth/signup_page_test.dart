import 'package:app/features/auth/views/signup_page.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

Widget wrap(Preferences preferences) {
  return ProviderScope(
    overrides: [preferenceProvider.overrideWithValue(preferences)],
    child: const MaterialApp(home: SignupPage()),
  );
}

Future<void> fillForm(
  WidgetTester tester, {
  String name = 'Ada Lovelace',
  String email = 'ada@example.com',
  String password = 'correct-horse',
  String? confirmPassword,
}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirm password'),
    confirmPassword ?? password,
  );
  await tester.pump();
}

void main() {
  group('SignupPage', () {
    testWidgets('renders name, email, password and confirm fields', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirm password'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Sign up'), findsOneWidget);
    });

    testWidgets('rejects an empty submit without calling the network', (
      tester,
    ) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign up'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      expect(preferences.getValue<String?>(PreferenceKeys.accessToken), isNull);
    });

    testWidgets('rejects a mismatched confirm password', (tester) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));

      await fillForm(tester, confirmPassword: 'something-else');

      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign up'));
      await tester.pump();

      expect(preferences.getValue<String?>(PreferenceKeys.accessToken), isNull);
    });

    testWidgets('clears the mismatch once the password is corrected', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      await fillForm(tester, password: 'first-password', confirmPassword: 'x');
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'x',
      );
      await tester.pump();

      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('accepts a fully valid form', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      await fillForm(tester);

      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Enter a valid email address'), findsNothing);
      expect(find.text('Password must be at least 8 characters'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('toggles each password field independently', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
