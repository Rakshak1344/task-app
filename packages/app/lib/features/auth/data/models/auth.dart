import 'package:app/features/auth/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';

part 'auth.g.dart';

@freezed
sealed class Auth with _$Auth {
  const Auth._();

  const factory Auth({required User user, required String accessToken}) = _Auth;

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
}
