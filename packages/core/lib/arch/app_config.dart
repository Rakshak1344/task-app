import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

abstract class AppConfig {
  static AppConfig? _instance;

  List<Override>? _overrides;

  static AppConfig get instance => _instance!;

  AppConfig() {
    _instance = this;
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'AppNavigator',
  );

  Future<void> initDependencies();

  FutureOr<Widget> onInit({required Widget child});

  Future<Widget> init({required Widget child}) async {
    WidgetsFlutterBinding.ensureInitialized();
    await initDependencies();

    var app = await onInit(child: child);

    return ProviderScope(
      overrides: _overrides ?? await overrides(),
      observers: await observers(),
      child: app,
    );
  }

  FutureOr<List<ProviderObserver>> observers();

  List<Override> overrides();
}
