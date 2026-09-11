import 'package:app/navigation/app_route_name.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/navigation/middlewares/navigation_middleware.dart';
import 'package:core/arch/storage/preference.dart';

class AuthenticatedNavigationMiddleware extends NavigationMiddleware {
  @override
  String? onRedirect() {
    final token = ref
        .read(preferenceProvider)
        .getValue<String?>(PreferenceKeys.accessToken);

    if (token == null || token.isEmpty) {
      return namedLocation(AppRouteName.auth.login);
    }

    if (state.uri.toString() == namedLocation(AppRouteName.root)) {
      return namedLocation(AppRouteName.tasks.list);
    }

    return null;
  }
}
