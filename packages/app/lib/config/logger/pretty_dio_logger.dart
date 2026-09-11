import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pretty_dio_logger.g.dart';

/// keepAlive: held by the keepAlive [dioProvider] for the app's lifetime.
@Riverpod(keepAlive: true)
PrettyDioLogger prettyDioLogger(Ref ref) {
  return PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: false,
    maxWidth: 90,
  );
}
