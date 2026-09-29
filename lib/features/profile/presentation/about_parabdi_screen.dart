import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_theme.dart';

/// About Parabdi — simple premium brand screen. The version is read at
/// runtime from the installed package metadata (package_info_plus),
/// falling back to the pubspec version string when unavailable.
final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class AboutParabdiScreen extends ConsumerWidget {
  const AboutParabdiScreen({super.key});

  // Fallback kept in sync with pubspec.yaml `version:`.
  static const String kAppVersionFallback = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(_packageInfoProvider);
    final version = packageInfoAsync.maybeWhen(
      data: (info) => info.version,
      orElse: () => kAppVersionFallback,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Parabdi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s20),
                child: Text(
                  'Parabdi brings homestyle Gujarati vegetarian meals to your doorstep — '
                  'fresh thalis, seasonal shaak, soft rotlis and wholesome khichdi, '
                  'cooked every day in our cloud kitchen. Subscribe for daily tiffins '
                  'or order à la carte whenever hunger strikes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
