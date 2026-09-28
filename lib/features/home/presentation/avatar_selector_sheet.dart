import 'package:flutter/material.dart';
import 'avatar_selection_page.dart';

/// Backward-compatible wrapper that delegates to [AvatarSelectionPage].
///
/// Existing callers will continue to work without changes.
/// All avatar selection now opens the full-screen [AvatarSelectionPage].
class AvatarSelectorSheet {
  static const String fallbackAvatar = 'male_cricket_champ';

  static const List<String> maleAvatars = [
    'male_cricket_champ',
    'male_football_pro',
    'male_fit_fierce',
    'male_urban_explorer',
  ];

  static const List<String> femaleAvatars = [
    'female_cricket_queen',
    'female_fit_fabulous',
    'female_trendy_vibes',
    'female_urban_chic',
  ];

  static const List<String> allAvatars = [
    'male_cricket_champ',
    'male_football_pro',
    'male_fit_fierce',
    'male_urban_explorer',
    'female_cricket_queen',
    'female_fit_fabulous',
    'female_trendy_vibes',
    'female_urban_chic',
  ];

  static Future<String?> show(BuildContext context, {String? selected}) {
    return AvatarSelectionPage.show(context);
  }

  static bool isValidAvatarId(String id) =>
      AvatarSelectionPage.isValidAvatarIdStatic(id);

  static String assetFor(String id) {
    // Legacy mappings for backward compatibility.
    if (id == 'male') return 'assets/images/avatars/male_cricket_champ.svg';
    if (id == 'female') return 'assets/images/avatars/female_cricket_queen.svg';
    if (allAvatars.contains(id)) return 'assets/images/avatars/$id.svg';
    return 'assets/images/avatars/$fallbackAvatar.svg';
  }
}
