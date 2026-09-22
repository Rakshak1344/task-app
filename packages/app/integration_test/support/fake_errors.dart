import 'package:dio/dio.dart';

DioException dioError(int statusCode, Map<String, dynamic> body) {
  final requestOptions = RequestOptions(path: '/');

  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: body,
    ),
  );
}

DioException unauthorizedError() =>
    dioError(401, {'message': 'Invalid credentials'});

DioException validationError(Map<String, List<String>> errors) =>
    dioError(422, {'message': 'The given data was invalid.', 'errors': errors});

DioException notFoundError() => dioError(404, {'message': 'Not found.'});
