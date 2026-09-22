import 'package:core/test/test_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol/patrol.dart';

class PageRobot {
  final TestApp app;

  PageRobot(this.app);

  BuildContext get appContext => app.appContext;

  ProviderContainer get ref => app.container;

  PatrolIntegrationTester get $ => app.$;

  Future<void> go(String location, {Object? extra}) async {
    await app.go(location, extra: extra);
  }

  Future<void> goNamed(
    String location, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) async {
    await app.goNamed(
      location,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}
