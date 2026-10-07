import 'package:flutter/material.dart';

/// Universal customer-app refresh primitives.
///
/// One reusable architecture for every backend-driven screen: Home, Menu,
/// Categories, Foods, Banners, Shorts, Subscriptions, Delivery Slots,
/// Orders/Tracking, Notifications, Profile/Addresses and Favorites.
///
/// Rules enforced by these widgets:
/// - Refresh always performs a REAL backend fetch by invoking the screen's
///   existing repository/provider reload method (passed in as [onRefresh]).
///   No duplicate API or business logic lives here.
/// - Existing good data is never cleared by a failed refresh: StateNotifier
///   screens keep their lists (their `copyWith` only sets error flags), and
///   [AppRefreshIconButton] reports failures via snackbar instead of swapping
///   the body.
/// - Loading is always visible: [RefreshIndicator] spinner for scrollable
///   content, an inline spinner inside [AppRefreshIconButton] otherwise.

/// Shows the standard "refresh failed" snackbar. The previous good data
/// stays on screen; [onRetry] re-runs the same real backend fetch.
void showRefreshError(
  BuildContext context, {
  required String message,
  Future<void> Function()? onRetry,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      action: onRetry == null
          ? null
          : SnackBarAction(
              label: 'Retry',
              onPressed: () {
                onRetry();
              },
            ),
    ),
  );
}

/// Reusable pull-to-refresh wrapper for scrollable screens.
///
/// Wrap the screen's scrollable (ListView / GridView / CustomScrollView /
/// SingleChildScrollView with [AlwaysScrollableScrollPhysics]) and pass the
/// existing provider reload (e.g. `notifier.refresh`, `loadOrders`,
/// `loadCheckout`) as [onRefresh]. The indicator itself is the loading
/// state; errors surface through the screen's existing inline error/Retry
/// UI, whose notifier state is preserved.
class AppPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final double displacement;

  const AppPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.displacement = 40,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color ?? Theme.of(context).colorScheme.primary,
      displacement: displacement,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Reusable header/AppBar refresh button for non-scrollable screens (or
/// non-scrollable states such as full-screen loading/error/empty).
///
/// Runs the existing backend reload passed as [onRefresh] (real fetch, not
/// just `setState`), shows an inline spinner while it runs, and — when the
/// fetch throws or [hasError] reports provider error state afterwards —
/// shows the standard error snackbar with Retry instead of clearing the
/// screen's good data.
class AppRefreshIconButton extends StatefulWidget {
  final Future<void> Function() onRefresh;

  /// Inspects provider state after [onRefresh] completes. Return true when
  /// the refresh failed (existing error flag set) so a snackbar is shown.
  /// May be omitted when [onRefresh] itself throws on failure.
  final bool Function()? hasError;
  final String tooltip;
  final String errorMessage;
  final Color? color;
  final double size;

  const AppRefreshIconButton({
    super.key,
    required this.onRefresh,
    this.hasError,
    this.tooltip = 'Refresh',
    this.errorMessage = 'Could not refresh. Showing saved data.',
    this.color,
    this.size = 22,
  });

  @override
  State<AppRefreshIconButton> createState() => _AppRefreshIconButtonState();
}

class _AppRefreshIconButtonState extends State<AppRefreshIconButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    bool failed = false;
    try {
      await widget.onRefresh();
      if (!mounted) return;
      failed = widget.hasError?.call() ?? false;
    } catch (_) {
      if (!mounted) return;
      failed = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (failed && mounted) {
      showRefreshError(
        context,
        message: widget.errorMessage,
        onRetry: _run,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return IconButton(
        tooltip: widget.tooltip,
        onPressed: null,
        icon: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.color,
          ),
        ),
      );
    }
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: _run,
      icon: Icon(
        Icons.refresh_rounded,
        size: widget.size + 2,
        color: widget.color,
      ),
    );
  }
}
