import 'package:core/arch/app_config.dart';
import 'package:core/test/navigation/test_app_go_router_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol/patrol.dart';

abstract class TestApp with TestAppGoRouterHelper {
  bool _isSetup = false;

  bool get isSetup => _isSetup;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  late final PatrolIntegrationTester _$;

  @override
  PatrolIntegrationTester get $ {
    _assertNotInitialized();
    return _$;
  }

  late ProviderContainer container;

  void _assertNotInitialized() {
    if (!isSetup) {
      throw StateError("App is not setup");
    }

    if (!isInitialized) {
      throw StateError("App is not initialized");
    }
  }

  late final BuildContext _appContext;

  @override
  BuildContext get appContext {
    _assertNotInitialized();
    return _appContext;
  }

  Widget get app;

  TestApp();

  AppConfig get appConfig;

  Future<TestApp> setup({
    Future<void> Function(ProviderContainer)? onInit,
  }) async {
    if (isSetup) {
      debugPrint('Warning: App is already setup');
      debugPrint('Warning: Setting up again');
    }
    await beforeSetup();

    /// Couple of things are safe to assume here:
    /// For the setup phase, we might need providers.
    /// And we might need some overrides.
    /// So let's get the config first and then initialize the dependencies.
    var config = appConfig;
    await config.initDependencies();

    /// Here we are creating a container with the overrides and observers.
    /// This will be used for the setup phase.
    container = ProviderContainer(
      overrides: await config.overrides(),
      observers: await config.observers(),
    );

    await onSetup(container);
    await onInit?.call(container);

    container.dispose();

    _isSetup = true;
    return this;
  }

  Future<void> onSetup(ProviderContainer container);

  Future<void> init(PatrolIntegrationTester $) async {
    if (!isSetup) {
      await setup();
    }
    if (isInitialized) {
      debugPrint('Warning: App is already initialized');
      debugPrint('Warning: Initializing again');
    }
    _$ = $;
    var child = await appConfig.init(child: app);
    await $.pumpWidgetAndSettle(child);

    _appContext = AppConfig.navigatorKey.currentContext!;
    if (!_appContext.mounted) {
      throw StateError("App is not mounted");
    }

    container = ProviderScope.containerOf(_appContext);

    await $.pumpAndSettle();
    _isInitialized = true;
  }

  Future<void> beforeSetup() async {
    //
  }

  Future<void> dismissSnackBar() async {
    ScaffoldMessenger.of(appContext).removeCurrentSnackBar();
  }
}
