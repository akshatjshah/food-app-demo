import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/presentation/auth_provider.dart';

/// Rate Parabdi — honest local-only app rating. There is no general
/// app-rating backend endpoint (per-order reviews use /reviews with an
/// orderId), so this screen NEVER claims a review was submitted to a
/// server. The rating is stored on-device and shown back to the user.
/// Rating keys are per-customer in LocalStorage; the provider rebuilds on
/// account switch so shared devices never leak ratings across customers.
final _appRatingProvider = StateProvider<int>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return LocalStorage.appRating;
});

class RateParabdiScreen extends ConsumerStatefulWidget {
  const RateParabdiScreen({super.key});

  @override
  ConsumerState<RateParabdiScreen> createState() => _RateParabdiScreenState();
}

class _RateParabdiScreenState extends ConsumerState<RateParabdiScreen> {
  final _feedbackController =
      TextEditingController(text: LocalStorage.appFeedback ?? '');
  bool _saved = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _save(int rating) async {
    await LocalStorage.setAppRating(rating);
    await LocalStorage.setAppFeedback(_feedbackController.text.trim());
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Thanks! Your rating was saved on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = ref.watch(_appRatingProvider);
    // Keep the feedback field in sync with the signed-in customer: when
    // the account (and therefore the stored rating) changes, reload the
    // per-customer feedback instead of showing the previous user's text.
    ref.listen<int>(_appRatingProvider, (prev, next) {
      if (prev != next && mounted) {
        _feedbackController.text = LocalStorage.appFeedback ?? '';
        setState(() => _saved = false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Parabdi'),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant_menu_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 40),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text('How is Parabdi treating you?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s8),
            const Text('Tap a star to rate your experience',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: AppSpacing.s24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () =>
                      ref.read(_appRatingProvider.notifier).state = i + 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 44,
                      color: i < rating
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.s24),
            TextFormField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What do you love? (optional)',
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.r12)),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton(
              onPressed: rating == 0
                  ? null
                  : () => _save(rating),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: Text(_saved ? 'Rating Saved' : 'Save My Rating',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSpacing.s12),
            const Text(
              'Your rating is stored only on this device for now. '
              'To review a specific meal, please rate it from your Orders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
