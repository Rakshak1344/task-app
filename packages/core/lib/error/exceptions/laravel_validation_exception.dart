import 'dart:convert';

import 'package:core/error/exceptions/interfaces/renderable_exception.dart';
import 'package:core/error/exceptions/interfaces/reportable_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LaravelValidationException with RenderableException, ReportableException {
  final String serverMessage;
  final Map<String, List<String>> errors;

  late final String message;

  LaravelValidationException(this.serverMessage, this.errors) {
    var messageString = "";
    errors.forEach((key, value) {
      messageString += "$key: ${value.join(", ")}\n";
    });

    message = messageString;
  }

  static LaravelValidationException? fromDioError(DioException e) {
    if (e.response?.statusCode != 422) {
      return null;
    }

    /// Convert DioError into LaravelValidationException, if response code is 422
    var data = e.response?.data;
    if (data is String) {
      try {
        data = jsonDecode(e.response?.data);
      } catch (err) {
        return null;
      }
    }
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final message = data['message'] ?? data['error'];
    var errors = data['errors'];
    if (errors is! Map<String, dynamic>) {
      return LaravelValidationException(message, {});
    }

    var newErrorMap = <String, List<String>>{};
    errors.forEach((key, value) {
      if (value is! List<dynamic>) {
        return;
      }
      newErrorMap[key] = value.map((e) => e.toString()).toList();
    });

    return LaravelValidationException(message, newErrorMap);
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
