import 'package:core/test/storage/store.dart';

class MemoryDb {
  static MemoryDb _instance = MemoryDb._();

  MemoryDb._();

  static void init() {
    _instance = MemoryDb._();
  }

  factory MemoryDb() {
    return _instance;
  }

  List<Store> stores = [];
}