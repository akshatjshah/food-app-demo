import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String mealName;
  final String? foodItemId;

  const RatingScreen({
    super.key,
    required this.orderId,
    this.mealName = 'Gujarati Thali',
    this.foodItemId,
  });

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    // Backend requires foodItemId: resolve from the order when not passed.
    var foodItemId = widget.foodItemId;
    if (foodItemId == null || foodItemId.isEmpty) {
      try {
        final res = await ApiClient.instance.get('/orders/${widget.orderId}');
        final payload = res.data;
        final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
        final items = (data is Map ? data['items'] : null) as List?;
        final first = items != null && items.isNotEmpty ? items.first : null;
        foodItemId = first is Map
            ? (first['foodItemId'] ?? first['food_item_id'] ?? (first['foodItem'] is Map ? first['foodItem']['id'] : null))?.toString()
            : null;
      } catch (_) {}
    }
    if (foodItemId == null || foodItemId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Could not determine the ordered item.'),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = <String, dynamic>{
        'orderId': widget.orderId,
        'foodItemId': foodItemId,
        'rating': _rating,
      };
      final comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        data['comment'] = comment;
      }

      await ApiClient.instance.post('/reviews', data: data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data['error']?['message'] ?? 'Failed to submit review. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Something went wrong. Please try again.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Order'),
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
            const SizedBox(height: AppSpacing.s24),
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.restaurant_menu_rounded, color: Theme.of(context).colorScheme.primary, size: 36),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text('How was ${widget.mealName}?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s8),
            const Text('Your feedback helps us serve you better', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: AppSpacing.s32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 44,
                      color: i < _rating ? Colors.amber : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.s32),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.r12)),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
