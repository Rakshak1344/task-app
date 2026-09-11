import 'package:app/config/network/network_config.dart';
import 'package:app/features/tasks/data/models/task.dart';
import 'package:core/data/response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_task_repository.g.dart';

@Riverpod(keepAlive: true)
NetworkTaskRepository networkTaskRepository(Ref ref) {
  return NetworkTaskRepository(ref.read(dioProvider));
}

@RestApi()
abstract class NetworkTaskRepository {
  factory NetworkTaskRepository(Dio dio, {String baseUrl}) =
      _NetworkTaskRepository;

  @GET('/tasks')
  Future<PagedResponse<Task>> index(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @GET('/tasks/{id}')
  Future<ObjectResponse<Task>> show(@Path('id') int id);

  @POST('/tasks')
  Future<ObjectResponse<Task>> store(
    @Field() String title,
    @Field() String? description,
    @Field() String? status,
    @Field() String? priority,
    @Field('due_date') String? dueDate,
  );

  @PUT('/tasks/{id}')
  Future<ObjectResponse<Task>> update(
    @Path('id') int id,
    @Field() String title,
    @Field() String? description,
    @Field() String? status,
    @Field() String? priority,
    @Field('due_date') String? dueDate,
  );

  @DELETE('/tasks/{id}')
  Future<void> destroy(@Path('id') int id);
}