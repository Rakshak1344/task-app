import 'package:core/arch/app_config.dart';
import 'package:app/features/auth/navigation/authenticated_routes_provider.dart';
import 'package:app/features/auth/navigation/unauthenticated_routes_provider.dart';
import 'package:app/navigation/router_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/arch/navigation/route_provider.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Raw<GoRouter> goRouter(Ref ref) {
  var notifier = ref.read(routerProvider.notifier);

  return GoRouter(
    navigatorKey: AppConfig.navigatorKey,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: AppRouter().routes(),
  );
}

class AppRouter {
  /// Our application routes. Obtained through code generation
  List<RouteBase> routes() =>
      routeProviders().fold([], (prev, e) => [...prev, ...e.routes()]);

  List<RouteProvider> routeProviders() {
    return [UnauthenticatedRoutesProvider(), AuthenticatedRoutesProvider()];
  }
}
