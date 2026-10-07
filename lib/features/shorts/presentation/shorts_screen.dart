import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_refresh.dart';
import '../data/models/short_item.dart';
import '../data/repositories/shorts_repository.dart';

final shortsRepositoryProvider = Provider<ShortsRepository>((ref) {
  return ShortsRepository(ApiClient.instance);
});

final shortsFutureProvider = FutureProvider<List<ShortItem>>((ref) async {
  final repo = ref.read(shortsRepositoryProvider);
  return repo.getShorts();
});

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  late final PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recordView(String shortId) {
    ref.read(shortsRepositoryProvider).viewShort(shortId);
  }

  void _toggleLike(ShortItem item) async {
    final repo = ref.read(shortsRepositoryProvider);
    await repo.likeShort(item.id);
    ref.invalidate(shortsFutureProvider);
  }

  /// Re-fetches shorts from the backend via the existing provider.
  /// PageView cannot host pull-to-refresh, so the header button is the
  /// refresh affordance here. Good data stays until the new fetch lands;
  /// failures surface a snackbar with Retry.
  Future<void> _refreshShorts() async {
    ref.invalidate(shortsFutureProvider);
    try {
      await ref.read(shortsFutureProvider.future);
    } catch (_) {
      if (!mounted) return;
      showRefreshError(
        context,
        message: 'Could not refresh shorts. Showing saved data.',
        onRetry: _refreshShorts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortsAsync = ref.watch(shortsFutureProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: shortsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load shorts', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(shortsFutureProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (shorts) {
          if (shorts.isEmpty) {
            return const Center(
              child: Text('No shorts available', style: TextStyle(color: Colors.white54)),
            );
          }
          return PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: shorts.length,
            onPageChanged: (i) {
              _recordView(shorts[i].id);
            },
            itemBuilder: (context, index) {
              final item = shorts[index];
              final imageUrl = item.thumbnailUrl ?? item.videoUrl ?? '';
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade900),
                      errorWidget: (_, __, ___) => Container(color: Colors.grey.shade900, child: const Icon(Icons.error, color: Colors.white54)),
                    )
                  else
                    Container(color: Colors.grey.shade900),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 80,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? 'Untitled',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        if (item.description != null)
                          Text(item.description!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.visibility_outlined, color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text('${item.viewsCount} views', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(width: 16),
                            Icon(
                              item.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: item.isLiked ? Colors.red : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text('${item.likesCount} likes', style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 100,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(item),
                          child: Column(
                            children: [
                              Icon(
                                item.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: item.isLiked ? Colors.red : Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 2),
                              Text('${item.likesCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            const Icon(Icons.visibility_outlined, color: Colors.white, size: 28),
                            const SizedBox(height: 2),
                            Text('${item.viewsCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  // Header refresh: vertical PageView cannot host
                  // pull-to-refresh, so this button re-fetches shorts.
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: AppRefreshIconButton(
                        tooltip: 'Refresh shorts',
                        color: Colors.white,
                        size: 20,
                        errorMessage: 'Could not refresh shorts. Showing saved data.',
                        onRefresh: _refreshShorts,
                        hasError: () =>
                            ref.read(shortsFutureProvider).hasError,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
