import 'package:app/config/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_interceptor.g.dart';

@riverpod
AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(ref, () async {
    /// TODO: should parse the authToken
    return "";
  });
}

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
      /// Invalidate the auth token
      handler.reject(err);
      return;
    }
    handler.next(err);
  }

  Future<void> _addAuthHeader(RequestOptions options) async {
    var accessToken = await onFetchToken();

    if (accessToken != null) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }
  }
}
