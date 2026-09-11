
part of 'models.dart';

@freezed
sealed class MetaLink with _$MetaLink {
  factory MetaLink({String? url, required String label, required bool active}) =
      _MetaLink;

  factory MetaLink.fromJson(Map<String, dynamic> json) =>
      _$MetaLinkFromJson(json);
}
