import 'dart:convert';

import 'package:app/features/profile/views/profile_page.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

Widget wrap(Preferences preferences) {
  return ProviderScope(
    overrides: [preferenceProvider.overrideWithValue(preferences)],
    child: const MaterialApp(home: ProfilePage()),
  );
}

FakePreferences signedInAs({
  required String email,
  String? name,
}) {
  return FakePreferences({
    PreferenceKeys.accessToken: 'token-123',
    PreferenceKeys.user: jsonEncode({
      'id': 1,
      'email': email,
      'name': name,
      'avatar_url': null,
    }),
  });
}

void main() {
  group('ProfilePage', () {
    testWidgets('shows the logged in email and a logout button', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(signedInAs(email: 'ada@example.com')));
      await tester.pump();

      expect(find.text('Logged in as ada@example.com'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Log out'), findsOneWidget);
    });

    testWidgets('shows the name when the backend supplied one', (tester) async {
      await tester.pumpWidget(
        wrap(signedInAs(email: 'ada@example.com', name: 'Ada Lovelace')),
      );
      await tester.pump();

      expect(find.text('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('falls back to a placeholder before the user stream emits', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(FakePreferences()));

      expect(find.text('Logged in as —'), findsOneWidget);
    });

    testWidgets('clears the stored session on logout', (tester) async {
      final preferences = signedInAs(email: 'ada@example.com');
      await tester.pumpWidget(wrap(preferences));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pump();

      expect(preferences.getValue<String?>(PreferenceKeys.accessToken), isNull);
      expect(preferences.getValue<String?>(PreferenceKeys.user), isNull);
    });
  });
}
