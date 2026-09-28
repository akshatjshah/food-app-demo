import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import 'avatar_provider.dart';

class AvatarSelectionPage extends ConsumerStatefulWidget {
  const AvatarSelectionPage({super.key});

  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AvatarSelectionPage()),
    );
  }

  static String assetForStatic(String id) => assetFor(id);

  static bool isValidAvatarIdStatic(String id) =>
      maleAvatars.contains(id) || femaleAvatars.contains(id);

  @override
  ConsumerState<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends ConsumerState<AvatarSelectionPage> {
  late String _pending;

  @override
  void initState() {
    super.initState();
    _pending = ref.read(avatarProvider);
  }

  void _save(BuildContext context) async {
    if (_pending == ref.read(avatarProvider)) {
      Navigator.of(context).pop(null);
      return;
    }
    await ref.read(avatarProvider.notifier).setAvatar(_pending);
    Navigator.of(context).pop(_pending);
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Pick a look that feels like you',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'MEN',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                                    Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final id in maleAvatars)
                        SizedBox(
                          width: 140,
                          child: _AvatarCard(
                            id: id,
                            label: avatarLabels[id]!,
                            isSelected: _pending == id,
                            onTap: () => setState(() => _pending = id),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'WOMEN',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final id in femaleAvatars)
                        SizedBox(
                          width: 140,
                          child: _AvatarCard(
                            id: id,
                            label: avatarLabels[id]!,
                            isSelected: _pending == id,
                            onTap: () => setState(() => _pending = id),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      key: Key('avatar_$id'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primary.withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : [],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/avatars/$id.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? primary : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
