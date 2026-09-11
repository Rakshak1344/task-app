import 'dart:io';

import 'package:core/error/exceptions/interfaces/renderable_exception.dart';
import 'package:core/error/exceptions/interfaces/reportable_exception.dart';
import 'package:core/error/exceptions/no_resource_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NetworkExceptions with RenderableException, ReportableException {
  final String serverMessage;
  final Object? data;
  final bool _shouldReport;

  NetworkExceptions(this.serverMessage, this._shouldReport, {this.data});

  static NetworkExceptions fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return NetworkExceptions('Request was canceled by the server', false);
      case DioExceptionType.connectionTimeout:
        return NetworkExceptions('Connection to the server timed out', true);
      case DioExceptionType.connectionError:
        return NetworkExceptions('No Internet Connection', false);
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions(
          'Receive timeout while connecting to the server',
          true,
        );
      case DioExceptionType.badResponse:
        return _handleStatusCode(dioError.response?.statusCode,
            error: dioError);
      case DioExceptionType.sendTimeout:
        return NetworkExceptions(
          'Send timeout while connecting to the server',
          true,
        );
      case DioExceptionType.badCertificate:
        return NetworkExceptions('SSL certificate handshake failed', true);
      case DioExceptionType.unknown:
        if (dioError.error! is SocketException) {
          return NetworkExceptions('No Internet Connection', false);
        }
        return NetworkExceptions(
          'An unexpected error occurred.',
          true,
          data: dioError,
        );
      default:
        return NetworkExceptions('Something went wrong ', true, data: dioError);
    }
  }

  static NetworkExceptions _handleStatusCode(int? statusCode, {Object? error}) {
    switch (statusCode) {
      case 400:
        return NetworkExceptions(
          'Bad request: The server received invalid data',
          true,
        );
      case 401:
        return NetworkExceptions(
          'Authentication failed: Invalid credentials or session',
          false,
        );
      case 403:
        return NetworkExceptions(
          'Forbidden: The authenticated user is not allowed to access this resource',
          false,
          data: error,
        );
      case 404:
        return NoResourceException();
      case 405:
        return NetworkExceptions(
          'Method not allowed: The requested HTTP method is not supported',
          true,
        );
      case 409:
        return NetworkExceptions(
          'Conflict: Data conflict or resource already exists',
          true,
        );
      case 408:
        return NetworkExceptions(
          'Request timeout: The server took too long to respond',
          true,
        );
      case 415:
        return NetworkExceptions(
          'Unsupported media type: The server does not support the provided media type',
          true,
        );
      case 429:
        return NetworkExceptions(
          'Too many requests: Rate limit exceeded',
          true,
        );
      default:
        return NetworkExceptions(
          'Received an invalid status code: $statusCode',
          true,
        );
    }
  }

  @override
  Widget render() {
    return Center(child: Text(serverMessage));
  }

  @override
  String toString() {
    return serverMessage;
  }

  @override
  bool shouldReport() {
    return _shouldReport;
  }
}
