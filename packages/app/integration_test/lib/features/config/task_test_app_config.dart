import 'package:app/features/auth/repositories/network_auth_repository.dart';
import 'package:app/features/tasks/repositories/network_task_repository.dart';
import 'package:app/task_app.dart';
import 'package:core/arch/app_config.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:core/test/storage/memory_db.dart';
import 'package:core/test/test_app.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../test_app_config.dart';
import '../../../utils/test_app_auth.dart';
import '../../../utils/test_app_tasks.dart';
import '../auth/repositories/fake_auth_network_repository.dart';
import '../tasks/repositories/fake_task_repository.dart';

class TaskTestApp extends TestApp with TestAppAuth, TestAppTasks {
  final List<Override> overrides;
  final NetworkAuthRepository authRepository;
  final NetworkTaskRepository taskRepository;

  TaskTestApp({
    this.overrides = const [],
    NetworkAuthRepository? authRepository,
    NetworkTaskRepository? taskRepository,
  }) : authRepository = authRepository ?? FakeAuthNetworkRepository(),
       taskRepository = taskRepository ?? FakeTaskRepository();

  @override
  Widget get app => TaskApp();

  @override
  AppConfig get appConfig => TestAppConfig(
    riverpodOverrides: [
      networkAuthRepositoryProvider.overrideWith((ref) => authRepository),
      networkTaskRepositoryProvider.overrideWith((ref) => taskRepository),
      ...overrides,
    ],
  );

  @override
  Future<void> beforeSetup() async {
    Hive.resetAdapters();
    MemoryDb.init();
  }

  @override
  Future<void> onSetup(ProviderContainer container) async {
    await container.read(preferenceProvider).clear();
    Hive.resetAdapters();
    MemoryDb.init();
  }
}
