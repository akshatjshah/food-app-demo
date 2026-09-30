import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'avatar_image.dart';
import 'avatar_provider.dart';

/// Avatar personalization screen backed by the 8 exact PNG assets.
///
/// Sections (in order): "Male" (4), then "Female" (4). Each card is one
/// visual unit: the full-bleed source image at its OWN aspect ratio
/// ([avatarAspectRatioFor]) with a bottom fade derived from that image's
/// own background ([avatarFadeColorFor]) and the name overlaid on the fade.
/// Nothing is cropped, stretched, or letterboxed.
class AvatarSelectionPage extends ConsumerStatefulWidget {
  const AvatarSelectionPage({super.key});

  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AvatarSelectionPage()),
    );
  }

  static String assetForStatic(String id) => assetFor(id);

  static bool isValidAvatarIdStatic(String id) => isValidAvatarId(id);

  @override
  ConsumerState<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends ConsumerState<AvatarSelectionPage> {
  late String _pending;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pending = ref.read(avatarProvider);
  }

  Future<void> _select(String id) async {
    if (_saving) return;
    setState(() {
      _pending = id;
      _saving = true;
    });
    try {
      // Persist immediately so Profile (which watches avatarProvider)
      // updates instantly and survives restart / re-login.
      await ref.read(avatarProvider.notifier).setAvatar(id);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _save(BuildContext context) {
    Navigator.of(context).pop(_pending);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Choose Your Avatar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            key: const Key('save_avatar_button'),
            onPressed: () => _save(context),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  AppColors.accent.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: primary.withValues(alpha: 0.18)),
            ),
            child: const Text(
              'Pick a look that feels like you — your avatar shows across Parabdi.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _SectionHeader(title: 'Male', primary: primary),
                  const SizedBox(height: 12),
                  _AvatarGrid(
                    ids: maleAvatars,
                    pending: _pending,
                    onSelect: _select,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Female', primary: primary),
                  const SizedBox(height: 12),
                  _AvatarGrid(
                    ids: femaleAvatars,
                    pending: _pending,
                    onSelect: _select,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.primary});

  final String title;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ],
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.ids,
    required this.pending,
    required this.onSelect,
  });

  final List<String> ids;
  final String pending;
  final Future<void> Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    // Masonry-style 2-column layout: each card sizes itself from its OWN
    // source aspect ratio (via AspectRatio), so a fixed GridView
    // childAspectRatio can never force-crop or letterbox any avatar.
    // With 4 ids per section this builds two balanced columns.
    final left = <String>[];
    final right = <String>[];
    for (var i = 0; i < ids.length; i++) {
      if (i.isEven) {
        left.add(ids[i]);
      } else {
        right.add(ids[i]);
      }
    }
    Widget column(List<String> columnIds) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columnIds.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _AvatarCard(
                id: columnIds[i],
                label: avatarLabels[columnIds[i]]!,
                isSelected: pending == columnIds[i],
                onTap: () => onSelect(columnIds[i]),
              ),
            ],
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column(left),
        const SizedBox(width: 16),
        column(right),
      ],
    );
  }
}

class _AvatarCard extends ConsumerWidget {
  const _AvatarCard({
    required this.id,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    // Each card is ONE visual unit: full-bleed source image (own ratio) +
    // bottom fade derived from that image's own background + name overlay.
    // No inner padding/white box around the image, no separate label strip.
    final ratio = avatarAspectRatioFor(id);
    final fade = avatarFadeColorFor(id);
    final onFade = avatarOnFadeColorFor(id);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      key: Key('avatar_$id'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected ? primary : Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.18),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r16 - 1),
          child: AspectRatio(
            aspectRatio: ratio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full original PNG edge-to-edge. The box already matches
                // the source ratio, so cover fills exactly with no crop,
                // no stretch and no white gaps; the PNG background reaches
                // all four edges as authored (head to shoes visible).
                AvatarImage(avatarId: id, fit: BoxFit.cover),
                // Subtle bottom fade in the avatar's OWN background color,
                // clipped to the card bounds. Transparent over the lower
                // image, becoming the derived color near the name.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 88,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          fade.withValues(alpha: 0.0),
                          fade.withValues(alpha: 0.55),
                          fade.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                ),
                // Premium centered name resting on the fade — part of the
                // image, not a separate white strip.
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 10,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.3,
                      height: 1.2,
                      color: onFade,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(
                            alpha: onFade == Colors.white ? 0.35 : 0.18,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
