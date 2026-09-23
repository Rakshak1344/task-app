import 'package:app/config/task_app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class TestAppConfig extends TaskAppConfig {
  final List<Override> riverpodOverrides;

  TestAppConfig({required this.riverpodOverrides});

  @override
  List<Override> overrides() {
    var overrides = super.overrides();
    overrides.addAll(riverpodOverrides);

    return overrides;
  }
}
