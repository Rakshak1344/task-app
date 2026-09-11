import 'dart:async';

abstract class ObjectRepository<T> {
  // create / update
  Future<void> save(T? data);

  // Read
  T? get();

  Stream<T?> watch();

  // Delete
  Future<void> delete();
}

// CollectionRepository where T is List<T>
abstract class CollectionRepository<T> {
  // create / update
  Future<void> save(List<T> data);

  // Read
  List<T> get();

  Stream<List<T>> watch();

  // Delete
  Future<void> delete(T data);

  // Delete all
  Future<void> deleteAll();
}
