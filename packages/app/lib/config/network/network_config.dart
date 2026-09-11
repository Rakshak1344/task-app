import 'package:app/config/env.dart';
import 'package:app/config/logger/pretty_dio_logger.dart';
import 'package:app/config/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_config.g.dart';

@riverpod
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
