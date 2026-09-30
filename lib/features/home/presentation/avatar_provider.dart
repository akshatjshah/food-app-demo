import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../authentication/presentation/auth_provider.dart';

/// Default avatar (first Male PNG) shown when the user has not picked one yet.
const String kDefaultAvatarId = 'cricket_champ';

/// New PNG avatar ids — Male section first, in exact required order.
const List<String> maleAvatars = [
  'cricket_champ',
  'fit_fierce',
  'genz',
  'urban_man',
];

/// New PNG avatar ids — Female section after Male, in exact required order.
const List<String> femaleAvatars = [
  'fit_fabulous',
  'trendy',
  'women',
  'princess',
];

/// Display names for the 8 new PNG avatars (never filenames).
const Map<String, String> avatarLabels = {
  'cricket_champ': 'Cricket Champ',
  'fit_fierce': 'Fit & Fierce',
  'genz': 'Gen-Z',
  'urban_man': 'Urban Man',
  'fit_fabulous': 'Fit & Fabulous',
  'trendy': 'Trendy',
  'women': 'Women',
  'princess': 'Princess',
};

/// Exact PNG asset files (filenames contain "_" and "&" — do not rename).
const Map<String, String> avatarAssets = {
  'cricket_champ': 'assets/images/avatars/cricket_champ.png',
  'fit_fierce': 'assets/images/avatars/fit_&_fierce.png',
  'genz': 'assets/images/avatars/genz.png',
  'urban_man': 'assets/images/avatars/urban_man.png',
  'fit_fabulous': 'assets/images/avatars/fit_&_fabulous.png',
  'trendy': 'assets/images/avatars/trendy.png',
  'women': 'assets/images/avatars/women.png',
  'princess': 'assets/images/avatars/princess.png',
};

/// Legacy SVG avatar ids — kept untouched so existing users don't break.
/// New selection UI only offers the 8 PNGs above.
const List<String> legacyMaleAvatars = [
  'male_cricket_champ',
  'male_football_pro',
  'male_fit_fierce',
  'male_urban_explorer',
];

const List<String> legacyFemaleAvatars = [
  'female_cricket_queen',
  'female_fit_fabulous',
  'female_trendy_vibes',
  'female_urban_chic',
];

/// All ids ever considered valid (new PNG + legacy SVG + legacy shorthands).
bool isValidAvatarId(String id) =>
    avatarAssets.containsKey(id) ||
    legacyMaleAvatars.contains(id) ||
    legacyFemaleAvatars.contains(id);

/// True for one of the 8 new PNG avatars.
bool isPngAvatarId(String id) => avatarAssets.containsKey(id);

/// True for an old SVG avatar (fallback only, never offered for selection).
bool isLegacyAvatarId(String id) =>
    legacyMaleAvatars.contains(id) || legacyFemaleAvatars.contains(id);

/// Resolves any known avatar id to its exact asset path.
///
/// New PNG ids return their exact PNG file; legacy SVG ids return their exact
/// SVG file; unknown ids fall back to the default PNG.
String assetFor(String id) {
  if (avatarAssets.containsKey(id)) return avatarAssets[id]!;
  if (isLegacyAvatarId(id)) return 'assets/images/avatars/$id.svg';
  // Very old shorthand preferences.
  if (id == 'male') return avatarAssets['cricket_champ']!;
  if (id == 'female') return avatarAssets['fit_fabulous']!;
  return avatarAssets[kDefaultAvatarId]!;
}

const String fallbackAvatar = kDefaultAvatarId;

/// Actual source dimensions of the 8 PNG avatars (measured from the assets):
/// 7 are 1086x1448 (3:4); cricket_champ is 1024x1536 (2:3);
/// fit_fierce is 889x1769 (~1:2). The UI must respect each image's own
/// ratio instead of forcing one arbitrary square/height.
const Map<String, double> avatarAspectRatios = {
  'cricket_champ': 3 / 4,
  'fit_fierce': 3 / 4,
  'genz': 3 / 4,
  'urban_man': 3 / 4,
  'fit_fabulous': 3 / 4,
  'trendy': 3 / 4,
  'women': 3 / 4,
  'princess': 3 / 4,
};

double avatarAspectRatioFor(String id) => avatarAspectRatios[id] ?? (3 / 4);

/// Background-derived fade color per avatar, sampled from the actual PNG
/// backgrounds (corner/edge pixels). Each avatar fades into its OWN
/// background color behind the name — never one fixed green for all.
/// cricket_champ has a white background, so it fades into a warm sand
/// derived from its shading; the rest fade into their orange/pink/purple/
/// olive/tan/mauve backgrounds (darkened slightly for text readability).
const Map<String, Color> avatarFadeColors = {
  'cricket_champ': Color(0xFFCBBFA9),
  'fit_fierce': Color(0xFFC85E00),
  'genz': Color(0xFF4E4C38),
  'urban_man': Color(0xFF7D5F47),
  'fit_fabulous': Color(0xFF5F36AE),
  'trendy': Color(0xFFD14E7C),
  'women': Color(0xFFA17444),
  'princess': Color(0xFF5F4247),
};

/// Base/fallback fade for legacy SVG ids (kept Parabdi-green).
const Color kLegacyAvatarFade = Color(0xFF0E7A46);

/// Returns the fade color derived from the avatar's own background.
Color avatarFadeColorFor(String id) =>
    avatarFadeColors[id] ?? kLegacyAvatarFade;

/// Readable text color on top of the fade (dark on the near-white
/// cricket_champ fade, white everywhere else).
Color avatarOnFadeColorFor(String id) =>
    id == 'cricket_champ' ? const Color(0xFF3A3226) : Colors.white;

/// Uniform head-window for the small circular Home header avatar.
///
/// All 8 avatar sources are 3:4 portraits with the head in the same top
/// region, so ONE identical window serves every avatar (including future
/// additions — no per-avatar configuration needed):
/// - [kHomeFaceZoom]: uniform scale (source rendered this many times wider
///   than the circle; aspect preserved, never stretched).
/// - ([kHomeFaceCenterX], [kHomeFaceCenterY]): uniform window center as
///   source fractions. The circle shows a 1/[kHomeFaceZoom]-wide slice of
///   the source around this point: full head with a small background margin,
///   chin and hair inside, torso kept out as much as a shared window allows.
const double kHomeFaceZoom = 2.3;
const double kHomeFaceCenterX = 0.5;
const double kHomeFaceCenterY = 0.163;

/// Single source of truth for the current user's avatar.
class AvatarNotifier extends StateNotifier<String> {
  AvatarNotifier() : super(kDefaultAvatarId);

  /// Loads the avatar stored for [userId].
  ///
  /// Keeps any stored id (new PNG or legacy SVG) so existing users are never
  /// forced to change. Falls back to the legacy male/female preference
  /// (mapped onto the new PNG defaults), then to [kDefaultAvatarId].
  /// Persistence reuses [LocalStorage] per-user keys (`avatar_<userId>`);
  /// no new API, no new storage system, no schema change.
  void loadForUser(String? userId) {
    final uid = userId ?? 'guest';
    final stored = LocalStorage.getAvatarForUser(uid);
    if (stored != null && isValidAvatarId(stored)) {
      state = stored;
      return;
    }
    final legacy = LocalStorage.avatarStyle;
    if (legacy == 'female') {
      state = 'fit_fabulous';
      return;
    }
    state = kDefaultAvatarId;
  }

  /// Selects [avatarId] for the current user and persists it immediately.
  Future<void> setAvatar(String avatarId) async {
    if (!isValidAvatarId(avatarId)) return;
    state = avatarId;
    final uid = LocalStorage.getUserId() ?? 'guest';
    await LocalStorage.setAvatarForUser(uid, avatarId);
    await LocalStorage.setAvatarStyle(_isFemale(avatarId) ? 'female' : 'male');
  }

  bool _isFemale(String avatarId) {
    if (femaleAvatars.contains(avatarId)) return true;
    if (maleAvatars.contains(avatarId)) return false;
    return avatarId.startsWith('female');
  }
}

/// Single source of truth for the current user's avatar.
final avatarProvider = StateNotifierProvider<AvatarNotifier, String>((ref) {
  final notifier = AvatarNotifier();
  ref.listen(authProvider, (previous, next) {
    if (previous?.user?.id != next.user?.id) {
      notifier.loadForUser(next.user?.id);
    }
  });
  notifier.loadForUser(ref.read(authProvider).user?.id);
  return notifier;
});
