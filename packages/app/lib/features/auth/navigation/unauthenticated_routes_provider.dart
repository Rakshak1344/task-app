import 'package:app/features/auth/views/login_page.dart';
import 'package:app/features/auth/views/signup_page.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:core/arch/navigation/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnauthenticatedRoutesProvider extends RouteProvider {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/auth/login',
        name: AppRouteName.auth.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),

      GoRoute(
        path: '/auth/signup',
        name: AppRouteName.auth.signup,
        builder: (BuildContext context, GoRouterState state) =>
            const SignupPage(),
      ),
    ];
  }
}
