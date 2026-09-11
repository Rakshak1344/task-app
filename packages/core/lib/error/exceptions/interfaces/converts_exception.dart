import 'package:core/error/exceptions/laravel_validation_exception.dart';
import 'package:core/error/exceptions/server_error_exception.dart';
import 'package:dio/dio.dart';

import 'package:core/error/exceptions/network_exceptions.dart';

/// ignore: avoid_annotating_with_dynamic
typedef TypeExceptionAdapter = dynamic Function(dynamic);

mixin ConvertsException {
  Map<Type, List<TypeExceptionAdapter>> adapters = {
    DioException: [
      (e) => LaravelValidationException.fromDioError(e),
      (e) => ServerErrorException.fromDioError(e),
      (e) => NetworkExceptions.fromDioError(e),
    ],
  };

  void registerAdapter(Type exceptionType, TypeExceptionAdapter adapter) {
    adapters.putIfAbsent(exceptionType, () => []).add(adapter);
  }

  dynamic convertException(exception) {
    dynamic convertedException = exception;
    var exceptionType = convertedException.runtimeType;

    if (!adapters.containsKey(exceptionType)) {
      return convertedException;
    }

    var applicableAdapters = adapters[exceptionType]!;

    for (var adapter in applicableAdapters) {
      try {
        var result = adapter(convertedException);
        if (result != null) {
          // Recursively convert the exception
          convertedException = convertException(result);
          break;
        }
      } catch (e) {
        // If an exception occurs during conversion, break the loop and return the current converted exception
        break;
      }
    }

    return convertedException;
  }
}
