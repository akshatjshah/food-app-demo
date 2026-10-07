import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../address/data/models/address.dart';
import '../../address/presentation/address_provider.dart';
import '../../cart/data/models/cart.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../payments/presentation/payment_provider.dart';
import '../data/models/delivery_slot.dart';
import '../data/repositories/checkout_repository.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(ApiClient.instance);
});

class CheckoutState {
  final bool isLoading;
  final bool isPlacing;
  final String? error;
  final Cart? cart;
  final Map<String, dynamic>? validationResult;
  final List<Map<String, dynamic>> addresses;
  Map<String, dynamic>? selectedAddress;
  String selectedSlot;
  String? selectedSlotId;
  List<DeliverySlot> deliverySlots;
  bool isLoadingSlots;
  String? slotsError;
  String selectedPaymentMethod;
  String? specialInstructions;
  String? couponCode;

  CheckoutState({
    this.isLoading = false,
    this.isPlacing = false,
    this.error,
    this.cart,
    this.validationResult,
    this.addresses = const [],
    this.selectedAddress,
    this.selectedSlot = '',
    this.selectedSlotId,
    this.deliverySlots = const [],
    this.isLoadingSlots = false,
    this.slotsError,
    this.selectedPaymentMethod = 'upi',
    this.specialInstructions,
    this.couponCode,
  });

  CheckoutState copyWith({
    bool? isLoading,
    bool? isPlacing,
    String? error,
    Cart? cart,
    Map<String, dynamic>? validationResult,
    List<Map<String, dynamic>>? addresses,
    Map<String, dynamic>? selectedAddress,
    String? selectedSlot,
    String? selectedSlotId,
    List<DeliverySlot>? deliverySlots,
    bool? isLoadingSlots,
    String? slotsError,
    String? selectedPaymentMethod,
    String? specialInstructions,
    String? couponCode,
    bool clearError = false,
    bool clearSelectedAddress = false,
    bool clearSlotsError = false,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isPlacing: isPlacing ?? this.isPlacing,
      error: clearError ? null : (error ?? this.error),
      cart: cart ?? this.cart,
      validationResult: validationResult ?? this.validationResult,
      addresses: addresses ?? this.addresses,
      selectedAddress:
          clearSelectedAddress ? null : (selectedAddress ?? this.selectedAddress),
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
      deliverySlots: deliverySlots ?? this.deliverySlots,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      slotsError: clearSlotsError ? null : (slotsError ?? this.slotsError),
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      couponCode: couponCode ?? this.couponCode,
    );
  }

  double get itemTotal => validationResult?['itemTotal']?.toDouble() ?? cart?.itemTotal ?? 0.0;
  double get taxAmount => validationResult?['taxAmount']?.toDouble() ?? 0.0;
  double get platformFee => validationResult?['platformFee']?.toDouble() ?? 0.0;
  double get deliveryFee => validationResult?['deliveryFee']?.toDouble() ?? 0.0;
  double get grandTotal => validationResult?['grandTotal']?.toDouble() ?? 0.0;
  int get itemCount => validationResult?['itemCount'] ?? cart?.itemCount ?? 0;
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository _repo;
  final Ref _ref;

  CheckoutNotifier(this._repo, this._ref) : super(CheckoutState());

  AddressState get _addressState => _ref.read(addressNotifierProvider);
  AddressNotifier get _addressActions => _ref.read(addressNotifierProvider.notifier);

  Map<String, dynamic> _addressToMap(Address address) {
    return {
      'id': address.id,
      'type': address.label,
      'addressLine1': address.addressLine1,
      'addressLine2': address.addressLine2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'phone': address.phone,
      'isDefault': address.isDefault,
    };
  }

  Map<String, dynamic>? _resolveSelectedAddress(List<Map<String, dynamic>> addresses) {
    final shared = _addressState.selectedAddress;
    if (shared != null) {
      final match = addresses.where((a) => a['id'] == shared.id).firstOrNull;
      if (match != null) return match;
    }
    final def = addresses.where((a) => a['isDefault'] == true).firstOrNull;
    return def ?? (addresses.isNotEmpty ? addresses.first : null);
  }

  String _slotErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic> && err['message'] is String) {
        return err['message'] as String;
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return 'Failed to load delivery slots';
  }

  void _applySlots(List<DeliverySlot> slots) {
    String selectedSlot = state.selectedSlot;
    String? selectedSlotId = state.selectedSlotId;
    if (!slots.any((s) => s.value == selectedSlot)) {
      selectedSlot = slots.isNotEmpty ? slots.first.value : '';
      selectedSlotId = slots.isNotEmpty ? slots.first.id : null;
    } else {
      selectedSlotId =
          slots.where((s) => s.value == selectedSlot).firstOrNull?.id;
    }
    state = state.copyWith(
      isLoadingSlots: false,
      deliverySlots: slots,
      selectedSlot: selectedSlot,
      selectedSlotId: selectedSlotId,
      clearSlotsError: true,
    );
  }

  Future<void> loadCheckout() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingSlots: true,
      clearError: true,
      clearSlotsError: true,
    );
    try {
      final addressFuture = _addressActions.loadAddresses();
      final results = await Future.wait([
        _repo.getCart(),
        _repo.validateCart(),
      ]);

      final cart = results[0] as Cart;
      final validation = results[1] as Map<String, dynamic>;
      await addressFuture;

      final addresses = _addressState.addresses.map(_addressToMap).toList();
      final selected = _resolveSelectedAddress(addresses);

      state = state.copyWith(
        isLoading: false,
        cart: cart,
        validationResult: validation,
        addresses: addresses,
        selectedAddress: selected,
        clearSelectedAddress: selected == null,
      );

      // Slots load independently so a slot failure never blocks checkout.
      try {
        final slots = await _repo.getDeliverySlots();
        _applySlots(slots);
      } on DioException catch (e) {
        state = state.copyWith(
          isLoadingSlots: false,
          slotsError: _slotErrorMessage(e),
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic> &&
              data['error'] is Map<String, dynamic> &&
              (data['error'] as Map<String, dynamic>)['message'] is String
          ? (data['error'] as Map<String, dynamic>)['message'] as String
          : 'Failed to load checkout';
      state = state.copyWith(
        isLoading: false,
        isLoadingSlots: false,
        error: message,
      );
    }
  }

  /// Retry only the delivery-slot fetch (used by the slot section's
  /// loading/error/empty states). Preserves the rest of the checkout UI.
  Future<void> retryLoadSlots() async {
    state = state.copyWith(isLoadingSlots: true, clearSlotsError: true);
    try {
      final slots = await _repo.getDeliverySlots();
      _applySlots(slots);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingSlots: false,
        slotsError: _slotErrorMessage(e),
      );
    }
  }

  void selectAddress(Map<String, dynamic> address) {
    state = state.copyWith(selectedAddress: address);
    final match = _addressState.addresses
        .where((a) => a.id == address['id'])
        .firstOrNull;
    if (match != null) {
      _addressActions.selectAddress(match);
    }
  }

  void syncSelectedAddressFromShared() {
    final shared = _addressState.selectedAddress;
    if (shared == null) return;
    if (state.selectedAddress?['id'] == shared.id) return;
    final match = state.addresses.where((a) => a['id'] == shared.id).firstOrNull;
    if (match != null) {
      state = state.copyWith(selectedAddress: match);
    }
  }

  void syncAddressesFromShared() {
    final addresses = _addressState.addresses.map(_addressToMap).toList();
    final sameIds = addresses.length == state.addresses.length &&
        List.generate(addresses.length, (i) => addresses[i]['id']).join(',') ==
            List.generate(state.addresses.length, (i) => state.addresses[i]['id']).join(',');
    if (!sameIds) {
      state = state.copyWith(addresses: addresses);
    }
    syncSelectedAddressFromShared();
  }

  void selectSlot(String slot) {
    final match =
        state.deliverySlots.where((s) => s.value == slot).firstOrNull;
    state = state.copyWith(
      selectedSlot: slot,
      selectedSlotId: match?.id ?? state.selectedSlotId,
    );
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setSpecialInstructions(String? instructions) {
    state = state.copyWith(specialInstructions: instructions);
  }

  Future<String?> placeOrder() async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select a delivery address');
      return null;
    }
    if (state.selectedSlot.isEmpty) {
      state = state.copyWith(error: 'Please select a delivery slot');
      return null;
    }

    state = state.copyWith(isPlacing: true, clearError: true);
    try {
      final result = await _repo.createOrder(
        addressId: state.selectedAddress!['id'],
        deliverySlot: state.selectedSlot,
        specialInstructions: state.specialInstructions,
        couponCode: state.couponCode,
        paymentMethod: state.selectedPaymentMethod,
      );
      state = state.copyWith(isPlacing: false);
      return result['id'] as String;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic> &&
              data['error'] is Map<String, dynamic> &&
              (data['error'] as Map<String, dynamic>)['message'] is String
          ? (data['error'] as Map<String, dynamic>)['message'] as String
          : 'Failed to place order';
      state = state.copyWith(
        isPlacing: false,
        error: message,
      );
      return null;
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final repo = ref.read(checkoutRepositoryProvider);
  return CheckoutNotifier(repo, ref);
});

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).loadCheckout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);

    ref.listen(addressNotifierProvider.select((s) => s.selectedAddress?.id), (prev, next) {
      if (next != null && prev != next) {
        ref.read(checkoutProvider.notifier).syncSelectedAddressFromShared();
      }
    });

    ref.listen(addressNotifierProvider.select((s) => s.addresses), (prev, next) {
      if (!identical(prev, next)) {
        ref.read(checkoutProvider.notifier).syncAddressesFromShared();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Re-fetches cart + addresses + delivery slots via the existing
          // checkout loader. Covers states where pull is unavailable.
          AppRefreshIconButton(
            tooltip: 'Refresh checkout',
            errorMessage:
                'Could not refresh checkout. Showing saved data.',
            onRefresh: () =>
                ref.read(checkoutProvider.notifier).loadCheckout(),
            hasError: () => ref.read(checkoutProvider).error != null,
          ),
        ],
      ),
      body: checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : checkoutState.error != null && checkoutState.cart == null
              ? _buildErrorState(checkoutState)
              : checkoutState.cart?.items.isEmpty ?? true
                  ? _buildEmptyCartState()
                  : _buildCheckoutContent(context, checkoutState),
    );
  }

  Widget _buildErrorState(CheckoutState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(state.error ?? 'Unknown error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(checkoutProvider.notifier).loadCheckout(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Add items to proceed with checkout', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CheckoutState state) {
    return Column(
      children: [
        if (state.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                ),
              ],
            ),
          ),

        Expanded(
          child: AppPullToRefresh(
            onRefresh: () =>
                ref.read(checkoutProvider.notifier).loadCheckout(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressSection(context, state),
                  const Divider(height: 40),
                  _buildDeliverySlotSection(context, state),
                  const Divider(height: 40),
                  _buildPaymentSection(context, state),
                  const Divider(height: 40),
                  _buildOrderSummarySection(context, state),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),

        _buildPlaceOrderButton(context, state),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/location'),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        if (state.selectedAddress != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.selectedAddress!['type'] ?? 'Address',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCheckoutAddress(state.selectedAddress!),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit address',
                    onPressed: () => context.push(
                      '/addresses/edit/${state.selectedAddress!['id']}',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: const Text('Add delivery address'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/location'),
            ),
          ),
      ],
    );
  }

  String _formatCheckoutAddress(Map<String, dynamic> address) {
    final parts = [
      if (address['addressLine1'] != null &&
          (address['addressLine1'] as String).isNotEmpty)
        address['addressLine1'] as String,
      if (address['addressLine2'] != null &&
          (address['addressLine2'] as String).isNotEmpty)
        address['addressLine2'] as String,
      if (address['city'] != null && (address['city'] as String).isNotEmpty)
        address['city'] as String,
      if (address['postalCode'] != null &&
          (address['postalCode'] as String).isNotEmpty)
        address['postalCode'] as String,
    ];
    return parts.join(', ');
  }

  Widget _buildDeliverySlotSection(BuildContext context, CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Slot', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: _buildDeliverySlotBody(context, state),
        ),
      ],
    );
  }

  Widget _buildDeliverySlotBody(BuildContext context, CheckoutState state) {
    // Loading state — same container, spinner row.
    if (state.isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading delivery slots...', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    // API error state — message + retry, checkout stays usable.
    if (state.slotsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 20, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.slotsError!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(checkoutProvider.notifier).retryLoadSlots(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state — backend returned no active slots.
    if (state.deliverySlots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No delivery slots available right now.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(checkoutProvider.notifier).retryLoadSlots(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final selectedStillValid =
        state.deliverySlots.any((s) => s.value == state.selectedSlot);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedStillValid ? state.selectedSlot : null,
        hint: const Text('Select a delivery slot',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: state.deliverySlots.map((slot) {
          return DropdownMenuItem<String>(
            value: slot.value,
            child: Text(slot.label, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            ref.read(checkoutProvider.notifier).selectSlot(val);
          }
        },
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, CheckoutState state) {
    final methods = [
      {'name': 'UPI / GPay / PhonePe', 'code': 'upi', 'icon': Icons.bolt_rounded},
      {'name': 'Credit or Debit Card', 'code': 'card', 'icon': Icons.credit_card_rounded},
      {'name': 'Net Banking', 'code': 'net_banking', 'icon': Icons.account_balance_rounded},
      {'name': 'Cash on Delivery', 'code': 'cod', 'icon': Icons.payments_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s12),
        Column(
          children: methods.map((method) {
            final isSelected = state.selectedPaymentMethod == method['code'];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: ListTile(
                leading: Icon(method['icon'] as IconData, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                title: Text(method['name'] as String, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                trailing: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                onTap: () => ref.read(checkoutProvider.notifier).selectPaymentMethod(method['code'] as String),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection(BuildContext context, CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              children: [
                ...?state.cart?.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item.foodItem.name} x${item.quantity}', style: const TextStyle(fontSize: 14)),
                        ),
                        Text('₹${item.itemTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
                const Divider(),
                _buildPriceRow('Item Total', '₹${state.itemTotal.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                _buildPriceRow('Delivery Fee', state.deliveryFee == 0 ? 'FREE' : '₹${state.deliveryFee.toStringAsFixed(0)}',
                    isFree: state.deliveryFee == 0),
                const SizedBox(height: 4),
                _buildPriceRow('Platform Fee', '₹${state.platformFee.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                _buildPriceRow('GST (5%)', '₹${state.taxAmount.toStringAsFixed(0)}'),
                const Divider(height: 20),
                _buildPriceRow('Grand Total', '₹${state.grandTotal.toStringAsFixed(0)}', isBold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: isFree ? AppColors.success : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context, CheckoutState state) {
    final paymentState = ref.watch(paymentProvider);
    final isProcessing = state.isPlacing || paymentState.isProcessing;
    final isCod = state.selectedPaymentMethod == 'cod';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing || state.cart?.items.isEmpty == true
                ? null
                : () => _placeOrder(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                : Text(
                    isCod
                        ? 'Place Order  •  ₹${state.grandTotal.toStringAsFixed(0)}'
                        : 'Pay & Place Order  •  ₹${state.grandTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final orderId = await checkoutNotifier.placeOrder();
    if (!mounted) return;

    if (orderId == null) return;

    final isCod = ref.read(checkoutProvider).selectedPaymentMethod == 'cod';

    if (isCod) {
      ref.read(cartProvider.notifier).loadCart();
      context.go('/track/$orderId');
      return;
    }

    final grandTotal = ref.read(checkoutProvider).grandTotal;

    final paymentSuccess = await ref.read(paymentProvider.notifier).initiatePayment(
      orderId: orderId,
      amount: grandTotal,
      userPhone: '',
      userName: '',
    );

    if (!mounted) return;

    if (paymentSuccess) {
      ref.read(cartProvider.notifier).loadCart();
      context.go('/track/$orderId');
    } else {
      final paymentState = ref.read(paymentProvider);
      if (paymentState.status == PaymentStatus.failed && !paymentState.isCancelled) {
        _showPaymentFailedDialog(context, orderId, grandTotal);
      }
    }
  }

  void _showPaymentFailedDialog(BuildContext context, String orderId, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
        title: const Text('Payment Failed', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Your payment could not be processed. Please try again or choose a different payment method.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(paymentProvider.notifier).reset();
              context.go('/home');
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(paymentProvider.notifier).reset();
              _retryPayment(context, orderId, amount);
            },
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _retryPayment(BuildContext context, String orderId, double amount) async {
    final paymentSuccess = await ref.read(paymentProvider.notifier).initiatePayment(
      orderId: orderId,
      amount: amount,
      userPhone: '',
      userName: '',
    );

    if (!mounted) return;

    if (paymentSuccess) {
      ref.read(cartProvider.notifier).loadCart();
      context.go('/track/$orderId');
    }
  }
}
