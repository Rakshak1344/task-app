part of 'response.dart';

@JsonSerializable(genericArgumentFactories: true)
class CollectionResponse<T> {
  final List<T> data;

  CollectionResponse(this.data);

  factory CollectionResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) => _$CollectionResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) =>
      _$CollectionResponseToJson(this, toJsonT);
}
