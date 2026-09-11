import 'package:app/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskApp extends ConsumerStatefulWidget {
  const TaskApp({super.key});

  @override
  ConsumerState createState() => _TaskAppState();
}

class _TaskAppState extends ConsumerState<TaskApp> {
  var goRouter = ref.watch(goRouterProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "TaskApp",
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
    );
  }
}
