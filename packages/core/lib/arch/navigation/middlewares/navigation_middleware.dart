import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class NavigationMiddleware {
  late BuildContext _context;
  late GoRouterState _state;

  BuildContext get context => _context;

  GoRouterState get state => _state;

  String? call(BuildContext context, GoRouterState state) {
    _context = context;
    _state = state;
    return onRedirect();
  }

  String? onRedirect();
}
