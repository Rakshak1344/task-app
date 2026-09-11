part of 'models.dart';

@freezed
sealed class Links with _$Links {
  factory Links({String? first, String? last, String? prev, String? next}) =
      _Links;

  factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);
}
