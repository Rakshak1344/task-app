import 'dart:async';

import 'package:core/error/exceptions/interfaces/converts_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exception_adapter.g.dart';

@riverpod
ExceptionAdapter exceptionAdapter(Ref ref) {
  return ExceptionAdapter();
}

class ExceptionAdapter with ConvertsException {
  Future<T> run<T>(FutureOr<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw convertException(e);
    }
  }
}
