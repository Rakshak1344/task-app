import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';

abstract mixin class TestAppGoRouterHelper {
  BuildContext get appContext;

  PatrolIntegrationTester get $;

  Future<void> go(String path, {Object? extra}) async {
    appContext.go(path, extra: extra);
    await $.pumpAndSettle();
  }

  Future<void> goNamed(
      String pathName, {
        Map<String, String> pathParameters = const <String, String>{},
        Map<String, dynamic> queryParameters = const <String, dynamic>{},
        Object? extra,
      }) async {
    appContext.goNamed(
      pathName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
    await $.pumpAndSettle();
  }

  String getCurrentRoute() {
    var router = GoRouter.of(appContext);
    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;

    return matchList.uri.toString();
  }

  String getRouteFor(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
      }) {
    return GoRouter.of(appContext).namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }
}