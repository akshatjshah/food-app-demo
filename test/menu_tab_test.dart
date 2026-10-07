import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parabdi/features/cart/data/models/cart.dart';
import 'package:parabdi/features/cart/data/repositories/cart_repository.dart';
import 'package:parabdi/features/cart/presentation/cart_provider.dart';
import 'package:parabdi/features/home/data/models/home_data.dart';
import 'package:parabdi/features/home/data/repositories/home_repository.dart';
import 'package:parabdi/features/home/presentation/home_provider.dart';
import 'package:parabdi/features/menu/data/models/menu_food.dart';
import 'package:parabdi/features/menu/data/repositories/menu_repository.dart';
import 'package:parabdi/features/menu/presentation/menu_providers.dart';
import 'package:parabdi/features/menu/presentation/menu_tab.dart';

/// Single source of truth for the Menu chips under test: the same
/// [homeRepositoryProvider] that feeds Home → Explore Categories.
/// There is intentionally NO separate category fetch for Menu.
class FakeHomeRepository extends HomeRepository {
  FakeHomeRepository() : super(Dio());

  List<HomeCategory> categories = [];

  @override
  Future<List<BannerItem>> getBanners(
          {int timeoutSeconds = 8, int maxRetries = 1}) async =>
      [];

  @override
  Future<List<HomeCategory>> getCategories(
          {int timeoutSeconds = 8, int maxRetries = 1}) async =>
      categories;

  @override
  Future<List<HomeFood>> getFoods({
    String? categoryId,
    bool? isBestseller,
    bool? isVeg,
    bool? isHealthyPick,
    int? limit,
    int timeoutSeconds = 8,
    int maxRetries = 1,
  }) async =>
      [];
}

class FakeMenuRepository extends MenuRepository {
  FakeMenuRepository() : super(Dio());

  final List<Map<String, dynamic?>> calls = [];
  List<MenuFood> foods = [];

  @override
  Future<List<MenuFood>> getFoods({
    String? categoryId,
    String? search,
    bool? isVeg,
    bool? isBestseller,
    int take = 200,
  }) async {
    calls.add({
      'categoryId': categoryId,
      'search': search,
      'isVeg': isVeg,
      'isBestseller': isBestseller,
    });
    var result = foods;
    if (categoryId != null) {
      result = result.where((f) => f.categoryId == categoryId).toList();
    }
    if (search != null && search.isNotEmpty) {
      result = result
          .where((f) => f.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    if (isVeg == true) {
      result = result.where((f) => f.isVeg).toList();
    }
    return result;
  }
}

class FakeCartRepository extends CartRepository {
  FakeCartRepository() : super(Dio());

  final List<Map<String, dynamic>> stored = [];

  @override
  Future<Cart> getCart() async {
    var total = 0.0;
    var count = 0;
    final items = <CartItem>[];
    for (final m in stored) {
      final qty = m['quantity'] as int;
      final unit = m['price'] as double;
      total += unit * qty;
      count += qty;
      items.add(CartItem(
        id: m['id'] as String,
        foodItemId: m['foodItemId'] as String,
        quantity: qty,
        createdAt: DateTime(2026, 1, 1),
        foodItem: CartFoodItem(
          id: m['foodItemId'] as String,
          name: m['name'] as String,
          price: unit,
        ),
        unitPrice: unit,
        itemTotal: unit * qty,
      ));
    }
    return Cart(
      id: 'cart-1',
      items: items,
      itemTotal: total,
      itemCount: count,
    );
  }

  @override
  Future<void> addItem({
    required String foodItemId,
    required int quantity,
    List<Map<String, dynamic>>? customizationItems,
    String? specialInstructions,
  }) async {
    final existing = stored.where((m) => m['foodItemId'] == foodItemId);
    if (existing.isNotEmpty) {
      existing.first['quantity'] =
          (existing.first['quantity'] as int) + quantity;
      return;
    }
    stored.add({
      'id': 'item-${stored.length + 1}',
      'foodItemId': foodItemId,
      'name': 'Food $foodItemId',
      'price': 150.0,
      'quantity': quantity,
    });
  }
}

MenuFood _food(String id, String name,
    {String? categoryId, bool isVeg = true, int reviews = 0}) {
  return MenuFood(
    id: id,
    name: name,
    price: 100,
    categoryId: categoryId,
    isVeg: isVeg,
    reviewsCount: reviews,
    imageUrls: const [],
  );
}

Future<void> _settle(WidgetTester tester,
    {Duration total = const Duration(milliseconds: 1500)}) async {
  var elapsed = Duration.zero;
  const step = Duration(milliseconds: 100);
  while (elapsed < total) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Tall phone-like viewport so all list items are built (ListView is lazy).
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _settleUntil(WidgetTester tester, bool Function() condition,
    {int maxPumps = 30}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (condition()) return;
  }
}

void main() {
  late FakeHomeRepository homeRepo;
  late FakeMenuRepository menuRepo;
  late FakeCartRepository cartRepo;

  setUp(() {
    homeRepo = FakeHomeRepository()
      ..categories = const [
        HomeCategory(id: 'c-thali', name: 'Thali'),
        HomeCategory(id: 'c-rice', name: 'Rice & Biryani'),
        HomeCategory(id: 'c-breads', name: 'Breads'),
      ];
    menuRepo = FakeMenuRepository()
      ..foods = [
        _food('1', 'Gujarati Thali', categoryId: 'c-thali'),
        _food('2', 'Punjabi Thali', categoryId: 'c-thali'),
        _food('3', 'Paneer Biryani', categoryId: 'c-rice'),
        _food('4', 'Butter Naan', categoryId: 'c-breads'),
        _food('5', 'Cola', categoryId: 'c-breads', isVeg: true),
      ];
    cartRepo = FakeCartRepository();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(homeRepo),
        menuRepositoryProvider.overrideWithValue(menuRepo),
        cartRepositoryProvider.overrideWithValue(cartRepo),
      ],
      child: const MaterialApp(home: Scaffold(body: MenuTab())),
    );
  }

  testWidgets('"All" chip is rendered first, before Thali', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Thali'), findsOneWidget);

    final allPos = tester.getTopLeft(find.text('All'));
    final thaliPos = tester.getTopLeft(find.text('Thali'));
    expect(allPos.dx < thaliPos.dx, isTrue,
        reason: 'All must be the first category chip');
  });

  testWidgets('default selection is All and shows every food',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    expect(find.text('Gujarati Thali'), findsOneWidget);
    expect(find.text('Paneer Biryani'), findsOneWidget);
    expect(find.text('Butter Naan'), findsOneWidget);
    expect(menuRepo.calls.last['categoryId'], isNull);
  });

  testWidgets('tapping Thali filters; tapping All restores the full list',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.text('Thali'));
    await _settleUntil(tester,
        () => menuRepo.calls.last['categoryId'] == 'c-thali');
    await _settle(tester);

    expect(find.text('Gujarati Thali'), findsOneWidget);
    expect(find.text('Punjabi Thali'), findsOneWidget);
    expect(find.text('Butter Naan'), findsNothing);

    await tester.tap(find.text('All'));
    await _settleUntil(tester, () => menuRepo.calls.last['categoryId'] == null);
    await _settle(tester);

    expect(find.text('Gujarati Thali'), findsOneWidget);
    expect(find.text('Butter Naan'), findsOneWidget);
    expect(find.text('Paneer Biryani'), findsOneWidget);
  });

  testWidgets('header exposes Search and Cart actions', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byTooltip('Cart'), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(find.text('Parabdi Menu'), findsOneWidget);
  });

  testWidgets('inline search filters foods; clearing restores the menu',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'paneer');
    await tester.pump(const Duration(milliseconds: 400)); // debounce
    await _settleUntil(tester, () => menuRepo.calls.last['search'] == 'paneer');
    await _settle(tester);

    expect(menuRepo.calls.last['search'], 'paneer');
    expect(find.text('Paneer Biryani'), findsOneWidget);
    expect(find.text('Butter Naan'), findsNothing);

    // Clear the query → full menu returns, no stale results.
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 400));
    await _settleUntil(tester, () => menuRepo.calls.last['search'] == null);
    await _settle(tester);

    expect(find.text('Paneer Biryani'), findsOneWidget);
    expect(find.text('Butter Naan'), findsOneWidget);
    expect(find.text('Gujarati Thali'), findsOneWidget);
  });

  testWidgets('search with no results shows "No foods found"',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zzzz-no-match');
    await tester.pump(const Duration(milliseconds: 400));
    await _settleUntil(tester,
        () => menuRepo.calls.last['search'] == 'zzzz-no-match');
    await _settle(tester);

    expect(find.text('No foods found'), findsOneWidget);
    expect(find.text('Gujarati Thali'), findsNothing);
  });

  testWidgets('search works together with category filter', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.text('Thali'));
    await _settleUntil(tester,
        () => menuRepo.calls.last['categoryId'] == 'c-thali');

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'paneer');
    await tester.pump(const Duration(milliseconds: 400));
    await _settleUntil(tester, () => menuRepo.calls.last['search'] == 'paneer');
    await _settle(tester);

    // paneer is not in Thali → no results, clean empty state.
    expect(find.text('No foods found'), findsOneWidget);

    // Change search within category → result appears.
    await tester.enterText(find.byType(TextField), 'thali');
    await tester.pump(const Duration(milliseconds: 400));
    await _settleUntil(tester, () => menuRepo.calls.last['search'] == 'thali');
    await _settle(tester);

    expect(find.text('Gujarati Thali'), findsOneWidget);
    expect(menuRepo.calls.last['categoryId'], 'c-thali');
  });

  testWidgets('veg-only filter continues to work with search',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'cola');
    await tester.pump(const Duration(milliseconds: 400));
    await _settleUntil(tester, () => menuRepo.calls.last['search'] == 'cola');
    await _settle(tester);
    expect(find.text('Cola'), findsOneWidget);

    await tester.tap(find.byTooltip('Search')); // close search
    await tester.pump();
    await _settle(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Veg Only'));
    await _settleUntil(tester, () => menuRepo.calls.last['isVeg'] == true);
    await _settle(tester);

    expect(menuRepo.calls.last['isVeg'], isTrue);
  });

  testWidgets('tapping ADD actually inserts the item into cart state',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    expect(cartRepo.stored, isEmpty);

    await tester.tap(find.text('ADD').first);
    await _settleUntil(tester, () => cartRepo.stored.isNotEmpty);
    await _settle(tester);

    expect(cartRepo.stored.length, 1);
    expect(cartRepo.stored.single['quantity'], 1);

    // Header badge reflects the cart count immediately.
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('second ADD of the same food increments quantity',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    await tester.tap(find.text('ADD').first);
    await _settleUntil(tester, () => cartRepo.stored.isNotEmpty);
    await tester.pump();
    await tester.tap(find.text('ADD').first);
    await _settleUntil(tester, () => (cartRepo.stored.first['quantity'] as int) >= 2);
    await _settle(tester);

    expect(cartRepo.stored.first['quantity'], 2);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('chips mirror the shared category source exactly',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    // Same active categories as the shared source, in the same order.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Thali'), findsOneWidget);
    expect(find.text('Rice & Biryani'), findsOneWidget);
    expect(find.text('Breads'), findsOneWidget);
  });

  testWidgets('renamed category in the source renames the Menu chip',
      (tester) async {
    _usePhoneViewport(tester);
    homeRepo.categories = const [
      HomeCategory(id: 'c-thali', name: 'Thali'),
      HomeCategory(id: 'c-rice', name: 'Rice & Biryani'),
      HomeCategory(id: 'c-cold', name: 'Cold Drinks'),
    ];
    await tester.pumpWidget(buildApp());
    await _settle(tester);

    expect(find.text('Cold Drinks'), findsOneWidget);
    expect(find.text('Breads'), findsNothing);
  });

  testWidgets('removed category disappears from chips after refresh',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(buildApp());
    await _settle(tester);
    expect(find.text('Breads'), findsOneWidget);

    // Admin deletes/disables "Breads": it no longer exists as an active
    // backend category. After refresh (the same path pull-to-refresh uses)
    // the stale chip must be gone — no hardcoded fallback may reintroduce it.
    homeRepo.categories = const [
      HomeCategory(id: 'c-thali', name: 'Thali'),
      HomeCategory(id: 'c-rice', name: 'Rice & Biryani'),
    ];
    final ctx = tester.element(find.byType(MenuTab));
    ProviderScope.containerOf(ctx).read(homeProvider.notifier).refresh();
    await _settle(tester);

    expect(find.text('Breads'), findsNothing);
    expect(find.text('Thali'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}
