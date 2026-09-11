import 'package:app/config/env.dart';
import 'package:app/features/auth/repositories/local_auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final AsyncValueGetter<String?> onFetchToken;

  AuthInterceptor(this.ref, this.onFetchToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _addAuthHeader(options);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.baseUrl.startsWith(Env.baseUrl) &&
        err.response?.statusCode == 401) {
      /// Invalidate the auth token. Removing it fires the storage watch, which
      /// empties [AuthState] and sends the router back to login.
      ref.read(localAuthRepositoryProvider).delete();
      handler.reject(err);
      return;
    }
    handler.next(err);
  }

  Future<void> _addAuthHeader(RequestOptions options) async {
    var accessToken = await onFetchToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }
  }
}
