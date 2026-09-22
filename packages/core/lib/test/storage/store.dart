
import 'package:core/test/storage/memory_db.dart';

class Store<T> {
  T? value;

  Store._([this.value]);

  factory Store([T? value]) {
    var storeList = MemoryDb().stores.whereType<Store<T>>();
    if (storeList.isEmpty) {
      var store = Store<T>._(value);
      MemoryDb().stores.add(store);
      return store;
    }

    return storeList.first;
  }
}