import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parabdi/core/storage/local_storage.dart';
import 'package:parabdi/features/home/presentation/avatar_provider.dart';
import 'package:parabdi/features/home/presentation/avatar_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  test('PNG mapping uses exact filenames in exact order', () {
    expect(maleAvatars, ['cricket_champ', 'fit_fierce', 'genz', 'urban_man']);
    expect(femaleAvatars, ['fit_fabulous', 'trendy', 'women', 'princess']);
    expect(avatarLabels['cricket_champ'], 'Cricket Champ');
    expect(avatarLabels['fit_fierce'], 'Fit & Fierce');
    expect(avatarLabels['genz'], 'Gen-Z');
    expect(avatarLabels['urban_man'], 'Urban Man');
    expect(avatarLabels['fit_fabulous'], 'Fit & Fabulous');
    expect(avatarLabels['trendy'], 'Trendy');
    expect(avatarLabels['women'], 'Women');
    expect(avatarLabels['princess'], 'Princess');
    expect(assetFor('cricket_champ'), 'assets/images/avatars/cricket_champ.png');
    expect(assetFor('fit_fierce'), 'assets/images/avatars/fit_&_fierce.png');
    expect(assetFor('genz'), 'assets/images/avatars/genz.png');
    expect(assetFor('urban_man'), 'assets/images/avatars/urban_man.png');
    expect(assetFor('fit_fabulous'), 'assets/images/avatars/fit_&_fabulous.png');
    expect(assetFor('trendy'), 'assets/images/avatars/trendy.png');
    expect(assetFor('women'), 'assets/images/avatars/women.png');
    expect(assetFor('princess'), 'assets/images/avatars/princess.png');
    // Legacy SVG fallback still resolves.
    expect(assetFor('male_cricket_champ'), 'assets/images/avatars/male_cricket_champ.svg');
    expect(assetFor('female_cricket_queen'), 'assets/images/avatars/female_cricket_queen.svg');
    expect(isValidAvatarId('male_cricket_champ'), isTrue);
    expect(isValidAvatarId('nope'), isFalse);
  });

  testWidgets('selection page shows Male then Female with 8 PNG cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AvatarSelectionPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Avatar'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('MEN'), findsNothing);
    expect(find.text('WOMEN'), findsNothing);
    for (final label in ['Cricket Champ', 'Fit & Fierce', 'Gen-Z', 'Urban Man', 'Fit & Fabulous', 'Trendy', 'Women', 'Princess']) {
      expect(find.text(label), findsOneWidget);
    }
    // Male section appears before Female section.
    final maleY = tester.getTopLeft(find.text('Male')).dy;
    final femaleY = tester.getTopLeft(find.text('Female')).dy;
    expect(maleY < femaleY, isTrue);
    // Order within sections.
    expect(tester.getTopLeft(find.text('Cricket Champ')).dy <= tester.getTopLeft(find.text('Fit & Fierce')).dy, isTrue);
    expect(tester.getTopLeft(find.text('Fit & Fabulous')).dy <= tester.getTopLeft(find.text('Trendy')).dy, isTrue);
  });

  testWidgets('tapping a PNG avatar persists immediately', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AvatarSelectionPage())),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('avatar_princess'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(LocalStorage.getAvatarForUser('guest'), 'princess');
  });
}
