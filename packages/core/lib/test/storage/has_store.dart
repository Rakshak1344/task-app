import 'package:core/test/storage/store.dart';

mixin HasStore<T> {
  late Store<T> store = Store<T>(setInitialStoreValue());

  T? setInitialStoreValue() {
    return null;
  }
}
