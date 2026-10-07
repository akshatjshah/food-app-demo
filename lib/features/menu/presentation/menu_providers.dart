import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../home/presentation/home_provider.dart';
import '../data/models/menu_food.dart';
import '../data/models/menu_category.dart';
import '../data/repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ApiClient.instance);
});

// --- Categories ---
//
// Single source of truth: customer categories come from the backend
// `GET /categories` records via the existing Home categories repository
// ([homeRepositoryProvider], also watched by Home through `homeProvider`).
// Menu chips and the search browse list must NOT keep a second category
// fetch/filter logic — they read the same active, admin-ordered list so a
// rename / image change / disable / reorder (or a removed "Breads") is
// reflected in Home and Menu together after refresh.
//
// Kept as a [FutureProvider] alias for backward compatibility; new UI code
// should watch `homeProvider` categories directly.

final categoriesProvider = FutureProvider<List<MenuCategory>>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
  final cats = await repo.getCategories();
  return cats
      .map((c) => MenuCategory(
            id: c.id,
            name: c.name,
            icon: c.icon ?? '',
          ))
      .toList();
});

// --- Foods list ---

class FoodListState {
  final List<MenuFood> foods;
  final bool isLoading;
  final String? error;
  final String? categoryId;
  final String? search;
  final bool? isVeg;
  final bool? isBestseller;

  FoodListState({
    this.foods = const [],
    this.isLoading = false,
    this.error,
    this.categoryId,
    this.search,
    this.isVeg,
    this.isBestseller,
  });

  FoodListState copyWith({
    List<MenuFood>? foods,
    bool? isLoading,
    String? error,
    String? categoryId,
    String? search,
    bool? isVeg,
    bool? isBestseller,
    bool clearError = false,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearVeg = false,
    bool clearBestseller = false,
  }) {
    return FoodListState(
      foods: foods ?? this.foods,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      search: clearSearch ? null : (search ?? this.search),
      isVeg: clearVeg ? null : (isVeg ?? this.isVeg),
      isBestseller:
          clearBestseller ? null : (isBestseller ?? this.isBestseller),
    );
  }
}

class FoodListNotifier extends StateNotifier<FoodListState> {
  final MenuRepository _repo;
  int _requestSeq = 0;

  FoodListNotifier(this._repo) : super(FoodListState());

  Future<void> loadFoods() async {
    // Monotonic sequence: responses from stale/overlapping requests
    // (rapid category/search/veg changes) are discarded.
    final seq = ++_requestSeq;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final foods = await _repo.getFoods(
        categoryId: state.categoryId,
        search: state.search,
        isVeg: state.isVeg,
        isBestseller: state.isBestseller,
      );
      if (seq != _requestSeq) return;
      state = state.copyWith(foods: foods, isLoading: false);
    } on DioException catch (e) {
      if (seq != _requestSeq) return;
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['error']?['message'] ?? 'Failed to load foods',
      );
    } catch (_) {
      if (seq != _requestSeq) return;
      state = state.copyWith(isLoading: false, error: 'Failed to load foods');
    }
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
    );
    loadFoods();
  }

  void setVegFilter(bool? isVeg) {
    state = state.copyWith(isVeg: isVeg, clearVeg: isVeg == null);
    loadFoods();
  }

  void setSearch(String? search) {
    state = state.copyWith(
      search: search,
      clearSearch: search == null || search.trim().isEmpty,
    );
    loadFoods();
  }
}

final foodListProvider =
    StateNotifierProvider<FoodListNotifier, FoodListState>((ref) {
  final repo = ref.read(menuRepositoryProvider);
  return FoodListNotifier(repo)..loadFoods();
});

// --- Single food detail ---

final foodDetailProvider =
    FutureProvider.family<MenuFood, String>((ref, foodId) async {
  final repo = ref.read(menuRepositoryProvider);
  return repo.getFood(foodId);
});
