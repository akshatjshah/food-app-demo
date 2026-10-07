import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../data/models/address.dart';
import 'address_actions.dart';
import 'address_provider.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressNotifierProvider.notifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Header refresh covers empty/error states where pull-to-refresh
          // is unavailable. Same backend fetch; saved addresses are kept on
          // failure and a snackbar with Retry is shown instead.
          AppRefreshIconButton(
            tooltip: 'Refresh addresses',
            errorMessage:
                'Could not refresh addresses. Showing saved data.',
            onRefresh: () =>
                ref.read(addressNotifierProvider.notifier).loadAddresses(),
            hasError: () =>
                ref.read(addressNotifierProvider).errorMessage != null,
          ),
        ],
      ),
      body: _buildBody(context, addressState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/addresses/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddressState addressState) {
    if (addressState.isLoading && addressState.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (addressState.errorMessage != null && addressState.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.s16),
            Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s8),
            Text(addressState.errorMessage!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton.icon(
              onPressed: () => ref.read(addressNotifierProvider.notifier).loadAddresses(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (addressState.addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    return AppPullToRefresh(
      onRefresh: () => ref.read(addressNotifierProvider.notifier).loadAddresses(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: addressState.addresses.length,
        itemBuilder: (context, index) {
          final addr = addressState.addresses[index];
          final isSelected = addr.id == addressState.selectedAddress?.id;
          return _buildAddressCard(context, ref, addr, isSelected);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: AppSpacing.s16),
          Text('No addresses saved', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.s8),
          const Text('Add your delivery addresses for faster checkout', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, WidgetRef ref, Address addr, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r16),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    addressLabelIcon(addr.label),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('SELECTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  tooltip: 'Address actions',
                  onPressed: () => showAddressActionMenu(
                    context,
                    ref,
                    addr,
                    isSelected: isSelected,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              formatAddress(addr),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text('Phone: ${addr.phone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                if (!isSelected)
                  TextButton(
                    onPressed: () => ref.read(addressNotifierProvider.notifier).selectAddress(addr),
                    child: const Text('Select'),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => context.push('/addresses/edit/${addr.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                  onPressed: () =>
                      confirmDeleteAddress(context, ref, addr.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
