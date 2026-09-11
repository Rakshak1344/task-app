import 'package:app/config/task_app_config.dart';
import 'package:app/splash_app.dart';
import 'package:app/task_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SplashApp());

  TaskAppConfig().init(child: const TaskApp()).then((widget) {
    runApp(widget);
  });
}
