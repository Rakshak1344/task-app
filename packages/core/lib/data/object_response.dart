part of 'response.dart';

@JsonSerializable(genericArgumentFactories: true)
class ObjectResponse<T> {
  final T data;

  ObjectResponse(this.data);

  factory ObjectResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) => _$ObjectResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ObjectResponseToJson(this, toJsonT);
}
