// ignore_for_file: library_private_types_in_public_api

import 'package:app/features/auth/data/models/user.dart';
import 'package:data_fixture_dart/data_fixture_dart.dart';

extension UserFixture on User {
  static _UserFixtureFactory factory() => _UserFixtureFactory();
}

class _UserFixtureFactory extends JsonFixtureFactory<User> {
  static int _idSequence = 0;

  @override
  FixtureDefinition<User> definition() => define(
    (faker, [int index = 0]) => User(
      id: ++_idSequence,
      email: faker.internet.email(),
      name: faker.person.name(),
      avatarUrl: faker.image.loremPicsum(width: 200, height: 200),
    ),
  );

  @override
  JsonFixtureDefinition<User> jsonDefinition() =>
      defineJson((user, [int index = 0]) => user.toJson());

  JsonFixtureDefinition<User> withId(int id) =>
      redefineJson((user, [int index = 0]) => user.copyWith(id: id));

  JsonFixtureDefinition<User> withEmail(String email) =>
      redefineJson((user, [int index = 0]) => user.copyWith(email: email));

  JsonFixtureDefinition<User> withoutProfile() => redefineJson(
    (user, [int index = 0]) => user.copyWith(name: null, avatarUrl: null),
  );
}
