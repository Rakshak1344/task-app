import 'package:app/config/network/network_config.dart';
import 'package:app/features/auth/data/models/auth.dart';
import 'package:core/data/response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_auth_repository.g.dart';

@Riverpod(keepAlive: true)
NetworkAuthRepository networkAuthRepository(Ref ref) {
  return NetworkAuthRepository(ref.read(dioProvider));
}

@RestApi()
abstract class NetworkAuthRepository {
  factory NetworkAuthRepository(Dio dio, {String baseUrl}) =
      _NetworkAuthRepository;

  @POST('/login')
  Future<ObjectResponse<Auth>> login(
    @Field() String email,
    @Field() String password,
  );

  @POST('/signup')
  Future<ObjectResponse<Auth>> signup(
    @Field() String name,
    @Field() String email,
    @Field() String password,
  );

  @POST('/logout')
  Future<void> logout();
}
