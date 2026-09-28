import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../authentication/presentation/auth_provider.dart';

/// Default avatar shown when the user has not picked one yet.
const String kDefaultAvatarId = 'male_cricket_champ';

bool isValidAvatarId(String id) =>
    maleAvatars.contains(id) || femaleAvatars.contains(id);

const List<String> maleAvatars = [
  'male_cricket_champ',
  'male_football_pro',
  'male_fit_fierce',
  'male_urban_explorer',
];

const List<String> femaleAvatars = [
  'female_cricket_queen',
  'female_fit_fabulous',
  'female_trendy_vibes',
  'female_urban_chic',
];

const Map<String, String> avatarLabels = {
  'male_cricket_champ': 'Cricket Champ',
  'male_football_pro': 'Football Pro',
  'male_fit_fierce': 'Fit & Fierce',
  'male_urban_explorer': 'Urban Explorer',
  'female_cricket_queen': 'Cricket Queen',
  'female_fit_fabulous': 'Fit & Fabulous',
  'female_trendy_vibes': 'Trendy Vibes',
  'female_urban_chic': 'Urban Chic',
};

String assetFor(String id) {
  if (isValidAvatarId(id)) return 'assets/images/avatars/$id.svg';
  return 'assets/images/avatars/$kDefaultAvatarId.svg';
}

const String fallbackAvatar = kDefaultAvatarId;

/// Single source of truth for the current user's avatar.
class AvatarNotifier extends StateNotifier<String> {
  AvatarNotifier() : super(kDefaultAvatarId);

  /// Loads the avatar stored for [userId].
  ///
  /// Falls back to the legacy male/female preference (earlier app versions),
  /// then to [kDefaultAvatarId].
  void loadForUser(String? userId) {
    final uid = userId ?? 'guest';
    final stored = LocalStorage.getAvatarForUser(uid);
    if (stored != null && isValidAvatarId(stored)) {
      state = stored;
      return;
    }
    final legacy = LocalStorage.avatarStyle;
    if (legacy == 'female') {
      state = 'female_cricket_queen';
      return;
    }
    state = kDefaultAvatarId;
  }

  /// Selects [avatarId] for the current user and persists it.
  Future<void> setAvatar(String avatarId) async {
    if (!isValidAvatarId(avatarId)) return;
    state = avatarId;
    final uid = LocalStorage.getUserId() ?? 'guest';
    await LocalStorage.setAvatarForUser(uid, avatarId);
    await LocalStorage.setAvatarStyle(
      avatarId.startsWith('female') ? 'female' : 'male',
    );
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
