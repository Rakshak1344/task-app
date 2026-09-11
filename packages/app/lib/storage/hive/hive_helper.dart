import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();

    // No adapters to register. The preferences box is `Box<dynamic>` and only
    // ever holds primitives (the token, and the user encoded as a JSON string).
    // Adding a @HiveType model means adding hive_ce_generator and calling
    // `Hive.registerAdapters()` from the generated registrar here.
  }
}
