// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MenuFood _$MenuFoodFromJson(Map<String, dynamic> json) {
  return _MenuFood.fromJson(json);
}

/// @nodoc
mixin _$MenuFood {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get originalPrice => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int get reviewsCount => throw _privateConstructorUsedError;
  bool get isVeg => throw _privateConstructorUsedError;
  bool get isBestseller => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  List<String> get mealTags => throw _privateConstructorUsedError;
  List<CustomizationGroup> get customizationGroups =>
      throw _privateConstructorUsedError;

  /// Serializes this MenuFood to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuFood
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuFoodCopyWith<MenuFood> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuFoodCopyWith<$Res> {
  factory $MenuFoodCopyWith(MenuFood value, $Res Function(MenuFood) then) =
      _$MenuFoodCopyWithImpl<$Res, MenuFood>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    double? originalPrice,
    List<String> imageUrls,
    double? rating,
    int reviewsCount,
    bool isVeg,
    bool isBestseller,
    bool isFeatured,
    bool isActive,
    bool isAvailable,
    String? categoryId,
    String? categoryName,
    String? subcategory,
    List<String> mealTags,
    List<CustomizationGroup> customizationGroups,
  });
}

/// @nodoc
class _$MenuFoodCopyWithImpl<$Res, $Val extends MenuFood>
    implements $MenuFoodCopyWith<$Res> {
  _$MenuFoodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuFood
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? originalPrice = freezed,
    Object? imageUrls = null,
    Object? rating = freezed,
    Object? reviewsCount = null,
    Object? isVeg = null,
    Object? isBestseller = null,
    Object? isFeatured = null,
    Object? isActive = null,
    Object? isAvailable = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? subcategory = freezed,
    Object? mealTags = null,
    Object? customizationGroups = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            originalPrice: freezed == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            imageUrls: null == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviewsCount: null == reviewsCount
                ? _value.reviewsCount
                : reviewsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isVeg: null == isVeg
                ? _value.isVeg
                : isVeg // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBestseller: null == isBestseller
                ? _value.isBestseller
                : isBestseller // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryName: freezed == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String?,
            subcategory: freezed == subcategory
                ? _value.subcategory
                : subcategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            mealTags: null == mealTags
                ? _value.mealTags
                : mealTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            customizationGroups: null == customizationGroups
                ? _value.customizationGroups
                : customizationGroups // ignore: cast_nullable_to_non_nullable
                      as List<CustomizationGroup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuFoodImplCopyWith<$Res>
    implements $MenuFoodCopyWith<$Res> {
  factory _$$MenuFoodImplCopyWith(
    _$MenuFoodImpl value,
    $Res Function(_$MenuFoodImpl) then,
  ) = __$$MenuFoodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    double? originalPrice,
    List<String> imageUrls,
    double? rating,
    int reviewsCount,
    bool isVeg,
    bool isBestseller,
    bool isFeatured,
    bool isActive,
    bool isAvailable,
    String? categoryId,
    String? categoryName,
    String? subcategory,
    List<String> mealTags,
    List<CustomizationGroup> customizationGroups,
  });
}

/// @nodoc
class __$$MenuFoodImplCopyWithImpl<$Res>
    extends _$MenuFoodCopyWithImpl<$Res, _$MenuFoodImpl>
    implements _$$MenuFoodImplCopyWith<$Res> {
  __$$MenuFoodImplCopyWithImpl(
    _$MenuFoodImpl _value,
    $Res Function(_$MenuFoodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuFood
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? originalPrice = freezed,
    Object? imageUrls = null,
    Object? rating = freezed,
    Object? reviewsCount = null,
    Object? isVeg = null,
    Object? isBestseller = null,
    Object? isFeatured = null,
    Object? isActive = null,
    Object? isAvailable = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? subcategory = freezed,
    Object? mealTags = null,
    Object? customizationGroups = null,
  }) {
    return _then(
      _$MenuFoodImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        originalPrice: freezed == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        imageUrls: null == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviewsCount: null == reviewsCount
            ? _value.reviewsCount
            : reviewsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isVeg: null == isVeg
            ? _value.isVeg
            : isVeg // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBestseller: null == isBestseller
            ? _value.isBestseller
            : isBestseller // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryName: freezed == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String?,
        subcategory: freezed == subcategory
            ? _value.subcategory
            : subcategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        mealTags: null == mealTags
            ? _value._mealTags
            : mealTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        customizationGroups: null == customizationGroups
            ? _value._customizationGroups
            : customizationGroups // ignore: cast_nullable_to_non_nullable
                  as List<CustomizationGroup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuFoodImpl implements _MenuFood {
  const _$MenuFoodImpl({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    final List<String> imageUrls = const [],
    this.rating,
    this.reviewsCount = 0,
    this.isVeg = true,
    this.isBestseller = false,
    this.isFeatured = false,
    this.isActive = true,
    this.isAvailable = true,
    this.categoryId,
    this.categoryName,
    this.subcategory,
    final List<String> mealTags = const [],
    final List<CustomizationGroup> customizationGroups = const [],
  }) : _imageUrls = imageUrls,
       _mealTags = mealTags,
       _customizationGroups = customizationGroups;

  factory _$MenuFoodImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuFoodImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  final double? originalPrice;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final double? rating;
  @override
  @JsonKey()
  final int reviewsCount;
  @override
  @JsonKey()
  final bool isVeg;
  @override
  @JsonKey()
  final bool isBestseller;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final String? subcategory;
  final List<String> _mealTags;
  @override
  @JsonKey()
  List<String> get mealTags {
    if (_mealTags is EqualUnmodifiableListView) return _mealTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealTags);
  }

  final List<CustomizationGroup> _customizationGroups;
  @override
  @JsonKey()
  List<CustomizationGroup> get customizationGroups {
    if (_customizationGroups is EqualUnmodifiableListView)
      return _customizationGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customizationGroups);
  }

  @override
  String toString() {
    return 'MenuFood(id: $id, name: $name, description: $description, price: $price, originalPrice: $originalPrice, imageUrls: $imageUrls, rating: $rating, reviewsCount: $reviewsCount, isVeg: $isVeg, isBestseller: $isBestseller, isFeatured: $isFeatured, isActive: $isActive, isAvailable: $isAvailable, categoryId: $categoryId, categoryName: $categoryName, subcategory: $subcategory, mealTags: $mealTags, customizationGroups: $customizationGroups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuFoodImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewsCount, reviewsCount) ||
                other.reviewsCount == reviewsCount) &&
            (identical(other.isVeg, isVeg) || other.isVeg == isVeg) &&
            (identical(other.isBestseller, isBestseller) ||
                other.isBestseller == isBestseller) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            const DeepCollectionEquality().equals(other._mealTags, _mealTags) &&
            const DeepCollectionEquality().equals(
              other._customizationGroups,
              _customizationGroups,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    originalPrice,
    const DeepCollectionEquality().hash(_imageUrls),
    rating,
    reviewsCount,
    isVeg,
    isBestseller,
    isFeatured,
    isActive,
    isAvailable,
    categoryId,
    categoryName,
    subcategory,
    const DeepCollectionEquality().hash(_mealTags),
    const DeepCollectionEquality().hash(_customizationGroups),
  );

  /// Create a copy of MenuFood
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuFoodImplCopyWith<_$MenuFoodImpl> get copyWith =>
      __$$MenuFoodImplCopyWithImpl<_$MenuFoodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuFoodImplToJson(this);
  }
}

abstract class _MenuFood implements MenuFood {
  const factory _MenuFood({
    required final String id,
    required final String name,
    final String? description,
    required final double price,
    final double? originalPrice,
    final List<String> imageUrls,
    final double? rating,
    final int reviewsCount,
    final bool isVeg,
    final bool isBestseller,
    final bool isFeatured,
    final bool isActive,
    final bool isAvailable,
    final String? categoryId,
    final String? categoryName,
    final String? subcategory,
    final List<String> mealTags,
    final List<CustomizationGroup> customizationGroups,
  }) = _$MenuFoodImpl;

  factory _MenuFood.fromJson(Map<String, dynamic> json) =
      _$MenuFoodImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  double? get originalPrice;
  @override
  List<String> get imageUrls;
  @override
  double? get rating;
  @override
  int get reviewsCount;
  @override
  bool get isVeg;
  @override
  bool get isBestseller;
  @override
  bool get isFeatured;
  @override
  bool get isActive;
  @override
  bool get isAvailable;
  @override
  String? get categoryId;
  @override
  String? get categoryName;
  @override
  String? get subcategory;
  @override
  List<String> get mealTags;
  @override
  List<CustomizationGroup> get customizationGroups;

  /// Create a copy of MenuFood
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuFoodImplCopyWith<_$MenuFoodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomizationGroup _$CustomizationGroupFromJson(Map<String, dynamic> json) {
  return _CustomizationGroup.fromJson(json);
}

/// @nodoc
mixin _$CustomizationGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'minSelections')
  int get minSelect => throw _privateConstructorUsedError;
  @JsonKey(name: 'maxSelections')
  int get maxSelect => throw _privateConstructorUsedError;
  List<CustomizationItem> get items => throw _privateConstructorUsedError;

  /// Serializes this CustomizationGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomizationGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomizationGroupCopyWith<CustomizationGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomizationGroupCopyWith<$Res> {
  factory $CustomizationGroupCopyWith(
    CustomizationGroup value,
    $Res Function(CustomizationGroup) then,
  ) = _$CustomizationGroupCopyWithImpl<$Res, CustomizationGroup>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'minSelections') int minSelect,
    @JsonKey(name: 'maxSelections') int maxSelect,
    List<CustomizationItem> items,
  });
}

/// @nodoc
class _$CustomizationGroupCopyWithImpl<$Res, $Val extends CustomizationGroup>
    implements $CustomizationGroupCopyWith<$Res> {
  _$CustomizationGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomizationGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? minSelect = null,
    Object? maxSelect = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            minSelect: null == minSelect
                ? _value.minSelect
                : minSelect // ignore: cast_nullable_to_non_nullable
                      as int,
            maxSelect: null == maxSelect
                ? _value.maxSelect
                : maxSelect // ignore: cast_nullable_to_non_nullable
                      as int,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CustomizationItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomizationGroupImplCopyWith<$Res>
    implements $CustomizationGroupCopyWith<$Res> {
  factory _$$CustomizationGroupImplCopyWith(
    _$CustomizationGroupImpl value,
    $Res Function(_$CustomizationGroupImpl) then,
  ) = __$$CustomizationGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'minSelections') int minSelect,
    @JsonKey(name: 'maxSelections') int maxSelect,
    List<CustomizationItem> items,
  });
}

/// @nodoc
class __$$CustomizationGroupImplCopyWithImpl<$Res>
    extends _$CustomizationGroupCopyWithImpl<$Res, _$CustomizationGroupImpl>
    implements _$$CustomizationGroupImplCopyWith<$Res> {
  __$$CustomizationGroupImplCopyWithImpl(
    _$CustomizationGroupImpl _value,
    $Res Function(_$CustomizationGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomizationGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? minSelect = null,
    Object? maxSelect = null,
    Object? items = null,
  }) {
    return _then(
      _$CustomizationGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        minSelect: null == minSelect
            ? _value.minSelect
            : minSelect // ignore: cast_nullable_to_non_nullable
                  as int,
        maxSelect: null == maxSelect
            ? _value.maxSelect
            : maxSelect // ignore: cast_nullable_to_non_nullable
                  as int,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CustomizationItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomizationGroupImpl implements _CustomizationGroup {
  const _$CustomizationGroupImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'minSelections') this.minSelect = 0,
    @JsonKey(name: 'maxSelections') this.maxSelect = 1,
    final List<CustomizationItem> items = const [],
  }) : _items = items;

  factory _$CustomizationGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomizationGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'minSelections')
  final int minSelect;
  @override
  @JsonKey(name: 'maxSelections')
  final int maxSelect;
  final List<CustomizationItem> _items;
  @override
  @JsonKey()
  List<CustomizationItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CustomizationGroup(id: $id, name: $name, minSelect: $minSelect, maxSelect: $maxSelect, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomizationGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.minSelect, minSelect) ||
                other.minSelect == minSelect) &&
            (identical(other.maxSelect, maxSelect) ||
                other.maxSelect == maxSelect) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    minSelect,
    maxSelect,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of CustomizationGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomizationGroupImplCopyWith<_$CustomizationGroupImpl> get copyWith =>
      __$$CustomizationGroupImplCopyWithImpl<_$CustomizationGroupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomizationGroupImplToJson(this);
  }
}

abstract class _CustomizationGroup implements CustomizationGroup {
  const factory _CustomizationGroup({
    required final String id,
    required final String name,
    @JsonKey(name: 'minSelections') final int minSelect,
    @JsonKey(name: 'maxSelections') final int maxSelect,
    final List<CustomizationItem> items,
  }) = _$CustomizationGroupImpl;

  factory _CustomizationGroup.fromJson(Map<String, dynamic> json) =
      _$CustomizationGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'minSelections')
  int get minSelect;
  @override
  @JsonKey(name: 'maxSelections')
  int get maxSelect;
  @override
  List<CustomizationItem> get items;

  /// Create a copy of CustomizationGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomizationGroupImplCopyWith<_$CustomizationGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomizationItem _$CustomizationItemFromJson(Map<String, dynamic> json) {
  return _CustomizationItem.fromJson(json);
}

/// @nodoc
mixin _$CustomizationItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get additionalPrice => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CustomizationItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomizationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomizationItemCopyWith<CustomizationItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomizationItemCopyWith<$Res> {
  factory $CustomizationItemCopyWith(
    CustomizationItem value,
    $Res Function(CustomizationItem) then,
  ) = _$CustomizationItemCopyWithImpl<$Res, CustomizationItem>;
  @useResult
  $Res call({String id, String name, double additionalPrice, bool isActive});
}

/// @nodoc
class _$CustomizationItemCopyWithImpl<$Res, $Val extends CustomizationItem>
    implements $CustomizationItemCopyWith<$Res> {
  _$CustomizationItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomizationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? additionalPrice = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            additionalPrice: null == additionalPrice
                ? _value.additionalPrice
                : additionalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomizationItemImplCopyWith<$Res>
    implements $CustomizationItemCopyWith<$Res> {
  factory _$$CustomizationItemImplCopyWith(
    _$CustomizationItemImpl value,
    $Res Function(_$CustomizationItemImpl) then,
  ) = __$$CustomizationItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, double additionalPrice, bool isActive});
}

/// @nodoc
class __$$CustomizationItemImplCopyWithImpl<$Res>
    extends _$CustomizationItemCopyWithImpl<$Res, _$CustomizationItemImpl>
    implements _$$CustomizationItemImplCopyWith<$Res> {
  __$$CustomizationItemImplCopyWithImpl(
    _$CustomizationItemImpl _value,
    $Res Function(_$CustomizationItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomizationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? additionalPrice = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CustomizationItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        additionalPrice: null == additionalPrice
            ? _value.additionalPrice
            : additionalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomizationItemImpl implements _CustomizationItem {
  const _$CustomizationItemImpl({
    required this.id,
    required this.name,
    this.additionalPrice = 0.0,
    this.isActive = true,
  });

  factory _$CustomizationItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomizationItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final double additionalPrice;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CustomizationItem(id: $id, name: $name, additionalPrice: $additionalPrice, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomizationItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.additionalPrice, additionalPrice) ||
                other.additionalPrice == additionalPrice) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, additionalPrice, isActive);

  /// Create a copy of CustomizationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomizationItemImplCopyWith<_$CustomizationItemImpl> get copyWith =>
      __$$CustomizationItemImplCopyWithImpl<_$CustomizationItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomizationItemImplToJson(this);
  }
}

abstract class _CustomizationItem implements CustomizationItem {
  const factory _CustomizationItem({
    required final String id,
    required final String name,
    final double additionalPrice,
    final bool isActive,
  }) = _$CustomizationItemImpl;

  factory _CustomizationItem.fromJson(Map<String, dynamic> json) =
      _$CustomizationItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get additionalPrice;
  @override
  bool get isActive;

  /// Create a copy of CustomizationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomizationItemImplCopyWith<_$CustomizationItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
