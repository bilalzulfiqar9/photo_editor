import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image or Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF240046), Color(0xFF10002B)],
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
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement subscription
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
                        child: const Text(
                          'Subscribe for \$4.99/year',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(16),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement restore
                        },
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
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
