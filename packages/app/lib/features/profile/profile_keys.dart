import 'package:flutter/widgets.dart';

var profileKeys = ProfileKeys();

class ProfileKeys {
  ProfileKeys();

  final openButton = const Key('profile.open.button');
  final logoutButton = const Key('profile.logout.button');
}
