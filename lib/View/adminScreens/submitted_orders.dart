import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/order_model.dart';
import 'package:provider/provider.dart';

import '../../viewModel/order_data_provider.dart';

class SubmittedOrders extends StatelessWidget {
  static const String id = 'submitted_orders';

  const SubmittedOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<OrderDataProvider>(context, listen: false);

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Orders'),
      body: FutureBuilder(
        future: orderProvider.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error occurred: ${snapshot.error}'));
          }

          final orders = orderProvider.getOrders
            ..sort((a, b) => b.date.compareTo(a.date));

          if (orders.isEmpty) {
            return const _EmptyOrdersState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                onTap: () => _showOrderDetails(context, order),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    final orderUnits = _orderedUnits(order);
    final bonusUnits = _bonusUnits(order);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.74,
          minChildSize: 0.42,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: kappbarColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.receipt_long_outlined,
                            color: kappbarColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.area} • ${DateFormat('EEE, d MMM yyyy').format(order.date)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _OrderSummaryChip(
                        icon: Icons.inventory_2_outlined,
                        label: '$orderUnits order units',
                      ),
                      _OrderSummaryChip(
                        icon: Icons.redeem_outlined,
                        label: '$bonusUnits bonus units',
                      ),
                      _OrderSummaryChip(
                        icon: Icons.person_outline,
                        label: order.userName,
                      ),
                      if (order.discount != null && order.discount! > 0)
                        _OrderSummaryChip(
                          icon: Icons.local_offer_outlined,
                          label: '${order.discount!.toStringAsFixed(order.discount! % 1 == 0 ? 0 : 1)}% discount',
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ...order.products.map(_OrderProductTile.new),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static int _orderedUnits(OrderModel order) {
    return order.products.fold<int>(
      0,
      (sum, product) => sum + (int.tryParse(product.quantity) ?? 0),
    );
  }

  static int _bonusUnits(OrderModel order) {
    return order.products.fold<int>(
      0,
      (sum, product) => sum + (int.tryParse(product.bonus ?? '') ?? 0),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderedUnits = SubmittedOrders._orderedUnits(order);
    final bonusUnits = SubmittedOrders._bonusUnits(order);

    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: kappbarColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.storefront_outlined, color: kappbarColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.area} • ${DateFormat('EEE, d MMM').format(order.date)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _OrderSummaryChip(
                          icon: Icons.inventory_2_outlined,
                          label: '$orderedUnits units',
                        ),
                        _OrderSummaryChip(
                          icon: Icons.redeem_outlined,
                          label: '$bonusUnits bonus',
                        ),
                        if (order.discount != null && order.discount! > 0)
                          _OrderSummaryChip(
                            icon: Icons.local_offer_outlined,
                            label: '${order.discount!.toStringAsFixed(order.discount! % 1 == 0 ? 0 : 1)}%',
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderProductTile extends StatelessWidget {
  const _OrderProductTile(this.product);

  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.42),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: kappbarColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.medication_outlined, color: kappbarColor),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('Packing: ${product.packing ?? 'Not set'}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${product.quantity} units'),
            Text('${product.bonus ?? '0'} bonus'),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryChip extends StatelessWidget {
  const _OrderSummaryChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? kappbarColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: chipColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: kappbarColor),
            const SizedBox(height: 14),
            Text('No orders found',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Submitted product unit orders will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
