import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_editor/core/presentation/widgets/gradient_card.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';
import 'package:photo_editor/features/markup/presentation/pages/markup_screen.dart';
import 'package:photo_editor/features/stitching/presentation/pages/stitch_screen.dart';
import 'package:photo_editor/features/resize/presentation/pages/resize_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LongPic',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // TODO: Open Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section - Image Stitching
            GradientCard(
              title: 'Image Stitching',
              subtitle: 'Tap to select images',
              icon: Icons.layers_outlined, // Placeholder icon
              gradientColors: const [
                Color(0xFF8EC5FC),
                Color(0xFFE0C3FC),
              ], // Light Blue to Purple
              height: 180,
              onTap: () async {
                if (await PermissionHelper.requestStoragePermission()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StitchScreen(),
                    ),
                  );
                }
              },
            ),
            const Gap(24),
            Text(
              'More Features',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Gap(16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                GradientCard(
                  title: 'Watermarking',
                  icon: Icons.water_drop_outlined,
                  gradientColors: const [
                    Color(0xFF43E97B),
                    Color(0xFF38F9D7),
                  ], // Green
                  isTry: true,
                  expanded: true,
                  onTap: () {
                    // TODO: Nav to Watermarking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Coming Soon: Watermarking"),
                      ),
                    );
                  },
                ),
                GradientCard(
                  title: 'Overlay',
                  icon: Icons.layers,
                  gradientColors: const [
                    Color(0xFFA18CD1),
                    Color(0xFFFBC2EB),
                  ], // Purple
                  isTry: true,
                  expanded: true,
                  onTap: () {
                    // TODO: Nav to Overlay
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coming Soon: Overlay")),
                    );
                  },
                ),
                GradientCard(
                  title: 'Draw',
                  icon: Icons.brush_outlined,
                  gradientColors: const [
                    Color(0xFFFF9A9E),
                    Color(0xFFFECFEF),
                  ], // Pink
                  isTry: true,
                  expanded: true,
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarkupScreen(),
                        ),
                      );
                    }
                  },
                ),
                GradientCard(
                  title: 'Crop',
                  icon: Icons.crop,
                  gradientColors: const [
                    Color(0xFF4FACFE),
                    Color(0xFF00F2FE),
                  ], // Blue
                  expanded: true,
                  onTap: () {
                    // TODO: Nav to Crop
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coming Soon: Crop")),
                    );
                  },
                ),
                GradientCard(
                  title: 'Resize and Convert',
                  icon: Icons.compress,
                  gradientColors: const [
                    Color(0xFFF6D365),
                    Color(0xFFFDA085),
                  ], // Orange
                  expanded: true,
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResizeScreen(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
