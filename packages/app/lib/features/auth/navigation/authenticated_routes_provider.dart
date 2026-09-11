import 'package:app/features/auth/navigation/middlewares/authenticated_navigation_middleware.dart';
import 'package:app/features/profile/views/profile_page.dart';
import 'package:app/features/tasks/views/task_form_page.dart';
import 'package:app/features/tasks/views/task_list_page.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:core/arch/navigation/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticatedRoutesProvider extends RouteProvider {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/',
        name: AppRouteName.root,
        redirect: AuthenticatedNavigationMiddleware().call,
        routes: [
          GoRoute(
            path: 'tasks',
            name: AppRouteName.tasks.list,
            builder: (BuildContext context, GoRouterState state) =>
                const TaskListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRouteName.tasks.create,
                builder: (BuildContext context, GoRouterState state) =>
                    const TaskFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                name: AppRouteName.tasks.edit,
                builder: (BuildContext context, GoRouterState state) {
                  return TaskFormPage(
                    taskId: int.tryParse(state.pathParameters['id'] ?? ''),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            name: AppRouteName.profile.profile,
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
        ],
      ),
    ];
  }
}
