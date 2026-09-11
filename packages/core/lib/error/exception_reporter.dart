import 'package:core/error/exceptions/interfaces/reportable_exception.dart';

class ExceptionReporter {
  static final List<Type> _ignoredErrors = [];

  static void ignoreError(Type errorType) {
    _ignoredErrors.add(errorType);
  }

  static bool shouldReport(Object error) {
    if (error is ReportableException && !error.shouldReport()) {
      return false;
    }

    if (_ignoredErrors.contains(error.runtimeType)) {
      return false;
    }

    return true;
  }
}
