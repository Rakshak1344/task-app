part of 'models.dart';

@freezed
sealed class Meta with _$Meta {
  factory Meta({
    required int currentPage,
    required int lastPage,
    required int perPage,
    required String path,
    int? from,
    int? to,
    required int total,
    List<MetaLink>? metaLinks,
  }) = _Meta;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}
