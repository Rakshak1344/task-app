import 'package:core/error/exceptions/network_exceptions.dart';

class NoResourceException extends NetworkExceptions {
  static const String message =
      'Resource not found: The requested item does not exist on the server';

  NoResourceException() : super(message, false);
}
