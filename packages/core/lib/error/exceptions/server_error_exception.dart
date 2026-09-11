import 'package:core/error/exceptions/interfaces/renderable_exception.dart';
import 'package:core/error/exceptions/interfaces/reportable_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ServerErrorException with RenderableException, ReportableException {
  final String serverMessage;
  final Object? data;

  ServerErrorException(this.serverMessage, {this.data});

  static ServerErrorException? fromDioError(DioException e) {
    if (e.response?.statusCode != 500) {
      return null;
    }

    /// Convert DioError into ServerErrorException, if response code is 500
    final data = e.response?.data;
    if (data is! Map<String, dynamic>) {
      return ServerErrorException("Parse error", data: data);
    }

    final message = data['message'] ?? data['error'];
    var errors = data['errors'];
    if (errors is! Map<String, dynamic>) {
      return ServerErrorException(message, data: data);
    }

    var newErrorMap = <String, List<String>>{};
    errors.forEach((key, value) {
      if (value is! List<dynamic>) {
        return;
      }
      newErrorMap[key] = value.map((e) => e.toString()).toList();
    });

    return ServerErrorException(message);
  }

  @override
  Widget render() {
    return Center(child: Text(serverMessage));
  }

  @override
  String toString() {
    return serverMessage;
  }
}
