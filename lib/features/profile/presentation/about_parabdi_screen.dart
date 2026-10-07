import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../settings/presentation/app_content_provider.dart';

/// About Parabdi — simple premium brand screen. The version is read at
/// runtime from the installed package metadata (package_info_plus),
/// falling back to the pubspec version string when unavailable.
final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class AboutParabdiScreen extends ConsumerStatefulWidget {
  const AboutParabdiScreen({super.key});

  // Fallback kept in sync with pubspec.yaml `version:`.
  static const String kAppVersionFallback = '1.0.0';

  @override
  ConsumerState<AboutParabdiScreen> createState() =>
      _AboutParabdiScreenState();
}

class _AboutParabdiScreenState extends ConsumerState<AboutParabdiScreen> {
  @override
  void initState() {
    super.initState();
    // Always fetch the latest published copy on open — an Admin publish
    // made while the app runs must appear without restart.
    Future.microtask(
        () => ref.read(appContentProvider.notifier).load());
  }

  Future<void> _refresh() async {
    try {
      await ref.read(appContentProvider.notifier).load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final packageInfoAsync = ref.watch(_packageInfoProvider);
    final version = packageInfoAsync.maybeWhen(
      data: (info) => info.version,
      orElse: () => AboutParabdiScreen.kAppVersionFallback,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Parabdi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          AppRefreshIconButton(
            tooltip: 'Refresh about us',
            errorMessage:
                'Could not refresh about us. Showing saved data.',
            onRefresh: _refresh,
            hasError: () => false,
          ),
        ],
      ),
      body: AppPullToRefresh(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const SizedBox(height: AppSpacing.s16),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r24),
                boxShadow: AppShadows.premiumShadow(),
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text('Parabdi',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Pure Veg Gujarati Cloud Kitchen',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary)),
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Text('Version $version',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSpacing.s24),
            Builder(builder: (context) {
              // Dynamic About Us from backend Settings (Admin → Publish).
              // No hardcoded brand copy — server value wins; empty refetches.
              final content = ref.watch(appContentProvider);
              final about = content.values['about_us'];
              if ((about == null || about.isEmpty) &&
                  !content.isLoading) {
                Future.microtask(() => ref
                    .read(appContentProvider.notifier)
                    .refreshKey('about_us'));
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Text(
                    (about != null && about.isNotEmpty)
                        ? about
                        : (content.isLoading
                            ? 'Loading about us…'
                            : 'About us has not been published yet.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              );
            }),
            ],
          ),
        ),
      ),
    );
  }
}
