import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import 'package:gap/gap.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription Started Successfully!')),
          );
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(200),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Gap(20),
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      size: 64,
                      color: Color(0xFFFF006E),
                    ),
                  ),
                  const Gap(24),
                  const Text(
                    'Screen Stitch PRO',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'Unlock the full power of your creativity',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const Gap(48),
                  // Features
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      children: const [
                        _FeatureRow(text: 'Remove Watermark'),
                        Gap(16),
                        _FeatureRow(text: 'Ad-Free Experience'),
                        Gap(16),
                        _FeatureRow(text: 'Unlimited Stitching'),
                        Gap(16),
                        _FeatureRow(text: 'Premium Fonts & Filters'),
                        Gap(16),
                        _FeatureRow(text: 'Priority Support'),
                      ],
                    ),
                  ),
                  // Action Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        BlocBuilder<PaymentCubit, PaymentState>(
                          builder: (context, state) {
                            if (state is PaymentLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                            // Assuming we pre-load products even for Pro Screen or load them in initState
                            // Ideally ProScreen should also trigger loadProducts or rely on cached products
                            if (state is PaymentProductsLoaded) {
                              if (state.products.isEmpty) {
                                return Column(
                                  children: [
                                    const Text(
                                      "No products found",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const Gap(8),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<PaymentCubit>()
                                            .loadProducts();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                );
                              }

                              // Find yearly subscription or fallback
                              // Using cast to avoid type issues if generic inference is weird
                              // But explicit check above ensures we have products.
                              final product = state.products.firstWhere(
                                (p) => p.id == 'subscription_yearly',
                                orElse: () => state.products.first,
                              );

                              return ElevatedButton(
                                onPressed: () {
                                  context.read<PaymentCubit>().subscribeToPlan(
                                    product,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF006E),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Subscribe for ${product.price}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            return ElevatedButton(
                              onPressed: () {
                                context.read<PaymentCubit>().loadProducts();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: const Text('Load Products'),
                            );
                          },
                        ),
                        const Gap(16),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Restore purchase not implemented yet',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Restore Purchase',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF06D6A0), size: 24),
        const Gap(16),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
