// ignore_for_file: library_private_types_in_public_api

import 'package:app/features/auth/data/models/auth.dart';
import 'package:app/features/auth/data/models/user.dart';
import 'package:data_fixture_dart/data_fixture_dart.dart';

import 'user_factory.dart';

extension AuthFixture on Auth {
  static _AuthFixtureFactory factory() => _AuthFixtureFactory();
}

class _AuthFixtureFactory extends JsonFixtureFactory<Auth> {
  @override
  FixtureDefinition<Auth> definition() => define(
    (faker, [int index = 0]) => Auth(
      user: UserFixture.factory().makeSingle(),
      accessToken: 'token_${faker.guid.guid()}',
    ),
  );

  @override
  JsonFixtureDefinition<Auth> jsonDefinition() =>
      defineJson((auth, [int index = 0]) => auth.toJson());

  JsonFixtureDefinition<Auth> withUser(User user) =>
      redefineJson((auth, [int index = 0]) => auth.copyWith(user: user));

  JsonFixtureDefinition<Auth> withAccessToken(String accessToken) =>
      redefineJson(
        (auth, [int index = 0]) => auth.copyWith(accessToken: accessToken),
      );
}
