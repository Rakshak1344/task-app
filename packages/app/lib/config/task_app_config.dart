import 'dart:async';

import 'package:core/arch/app_config.dart';
import 'package:app/storage/hive/hive_helper.dart';
import 'package:app/storage/hive/hive_preference.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

class TaskAppConfig extends AppConfig {
  late HivePreference hivePreferencesInstance;

  @override
  Future<void> initDependencies() async {
    await HiveHelper.init();
    hivePreferencesInstance = await HivePreference.getInstance();
  }

  @override
  FutureOr<List<ProviderObserver>> observers() {
    return [];
  }

  @override
  FutureOr<Widget> onInit({required Widget child}) async {
    return child;
  }

  @override
  List<Override> overrides() {
    return [
      /// [AppConfig.init] awaits [initDependencies] before building the
      /// ProviderScope, so the box is guaranteed open by the time anything
      /// reads this provider.
      preferenceProvider.overrideWithValue(hivePreferencesInstance),
    ];
  }
}
