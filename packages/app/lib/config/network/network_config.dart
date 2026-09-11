import 'package:app/config/env.dart';
import 'package:app/config/logger/pretty_dio_logger.dart';
import 'package:app/config/network/interceptors/auth_interceptor.dart';
import 'package:app/features/auth/repositories/local_auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_config.g.dart';

/// keepAlive: the [Dio] instance is captured by [NetworkAuthRepository], which
/// is in turn held by the keepAlive [authServiceProvider]. If this were
/// auto-dispose it would be torn down immediately after that `ref.read`, and
/// its interceptors would be left holding a disposed [Ref].
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  var dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      headers: {"Accept": "application/json"},
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: Duration(seconds: 120),
    ),
  );

  dio.interceptors.addAll([
    ref.read(authInterceptorProvider),
    if (!kReleaseMode) ref.read(prettyDioLoggerProvider),
  ]);

  return dio;
}

/// keepAlive: [AuthInterceptor] captures this [Ref] and uses it on every
/// request, for the whole life of the [Dio] that owns it.
@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(
    ref,
    () async => ref.read(localAuthRepositoryProvider).get(),
  );
}
