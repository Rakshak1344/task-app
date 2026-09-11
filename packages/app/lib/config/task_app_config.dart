import 'dart:async';

import 'package:app/arch/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class TaskAppConfig extends AppConfig {
  @override
  Future<void> initDependencies() async {
    return;
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
  FutureOr<List<Override>> overrides() {
    return [];
  }
}
