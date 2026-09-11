import 'dart:convert';

import 'package:app/features/auth/data/models/auth.dart';
import 'package:core/data/response.dart';
import 'package:flutter_test/flutter_test.dart';

const signupResponseBody = '''
{
  "data": {
    "user": {
      "name": "Ada Lovelace",
      "email": "ada@example.com",
      "updated_at": "2026-09-11T15:22:58.000000Z",
      "created_at": "2026-09-11T15:22:58.000000Z",
      "id": 4
    },
    "access_token": "4|5Qdq3scd5GwmRAqj1DMkvdaemWkn2Zk0wR0dX74a5c2ce0a4"
  }
}
''';

void main() {
  test('parses the backend auth envelope', () {
    final response = ObjectResponse<Auth>.fromJson(
      json.decode(signupResponseBody) as Map<String, dynamic>,
      (json) => Auth.fromJson(json as Map<String, dynamic>),
    );

    final auth = response.data;

    expect(
      auth.accessToken,
      '4|5Qdq3scd5GwmRAqj1DMkvdaemWkn2Zk0wR0dX74a5c2ce0a4',
    );
    expect(auth.user.id, 4);
    expect(auth.user.email, 'ada@example.com');
    expect(auth.user.name, 'Ada Lovelace');

    expect(auth.user.avatarUrl, isNull);
  });
}