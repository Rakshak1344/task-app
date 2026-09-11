import 'package:core/arch/navigation/middlewares/navigation_middleware.dart';

/// The app-wide redirect, applied to every navigation.
///
/// Compose global, always-on redirects here via `MultipleNavigationMiddleware`
/// — force-update and under-maintenance gates are the usual tenants. Neither
/// feature exists yet, so this is a no-op.
///
/// Route-specific gating does not belong here; hang it off that route's own
/// `redirect:` instead, the way [AuthenticatedNavigationMiddleware] does.
class RootNavigationMiddleware extends NavigationMiddleware {
  @override
  String? onRedirect() => null;
}
