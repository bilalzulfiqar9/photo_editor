import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../cubit/payment_cubit.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

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
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPlanCard(
                context,
                'Monthly',
                '\$4.99/mo',
                'price_monthly_id',
              ),
              const Gap(16),
              _buildPlanCard(
                context,
                'Yearly',
                '\$39.99/yr',
                'price_yearly_id',
              ),
              const Gap(16),
              _buildPlanCard(
                context,
                'Lifetime',
                '\$99.99',
                'price_lifetime_id',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String title,
    String price,
    String planId,
  ) {
    return Card(
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        trailing: Text(price, style: Theme.of(context).textTheme.headlineSmall),
        onTap: () {
          context.read<PaymentCubit>().subscribeToPlan(planId);
        },
      ),
    );
  }
}
