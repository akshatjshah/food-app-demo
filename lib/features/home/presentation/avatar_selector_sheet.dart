import 'package:flutter/material.dart';
import 'avatar_provider.dart';
import 'avatar_selection_page.dart';

/// Backward-compatible wrapper that delegates to [AvatarSelectionPage].
///
/// Existing callers continue to work without changes. Avatar selection opens
/// the full-screen [AvatarSelectionPage] with the 8 new PNG avatars; old SVG
/// ids remain resolvable via [assetFor] for stored fallbacks.
class AvatarSelectorSheet {
  static const String fallbackAvatar = kDefaultAvatarId;

  static const List<String> maleAvatars = [
    'cricket_champ',
    'fit_fierce',
    'genz',
    'urban_man',
  ];

  static const List<String> femaleAvatars = [
    'fit_fabulous',
    'trendy',
    'women',
    'princess',
  ];

  static const List<String> allAvatars = [
    'cricket_champ',
    'fit_fierce',
    'genz',
    'urban_man',
    'fit_fabulous',
    'trendy',
    'women',
    'princess',
  ];

  static Future<String?> show(BuildContext context, {String? selected}) {
    return AvatarSelectionPage.show(context);
  }

  static bool isValidAvatarId(String id) =>
      AvatarSelectionPage.isValidAvatarIdStatic(id);

  static String assetFor(String id) => assetForAvatar(id);
}

/// Top-level alias kept for callers importing only the sheet.
String assetForAvatar(String id) => assetFor(id);
