part of 'response.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResponse<T> {
  final List<T> data;
  final Meta meta;
  final Links links;

  PagedResponse(this.data, this.meta, this.links);

  factory PagedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) => _$PagedResponseFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) =>
      _$PagedResponseToJson(this, toJsonT);
}
