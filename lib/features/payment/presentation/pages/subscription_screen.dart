import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../cubit/payment_cubit.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Plans')),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription Successful!')),
            );
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentProductsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...state.products.map(
                  (product) => _buildPlanCard(context, product),
                ),
                const Gap(32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<PaymentCubit>().restorePurchases();
                    },
                    child: const Text("Restore Purchases"),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No products available"),
                TextButton(
                  onPressed: () {
                    context.read<PaymentCubit>().loadProducts();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, ProductDetails product) {
    return Card(
      child: ListTile(
        title: Text(
          product.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(product.description),
        trailing: Text(
          product.price,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        onTap: () {
          context.read<PaymentCubit>().subscribeToPlan(product);
        },
      ),
    );
  }
}
