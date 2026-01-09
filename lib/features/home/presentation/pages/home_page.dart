import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:photo_editor/core/presentation/widgets/hero_feature_card.dart';
import 'package:photo_editor/core/presentation/widgets/tool_card.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';
import 'package:photo_editor/features/crop/presentation/pages/crop_screen.dart';
import 'package:photo_editor/features/markup/presentation/pages/markup_screen.dart';
import 'package:photo_editor/features/overlay/presentation/pages/overlay_screen.dart';
import 'package:photo_editor/features/resize/presentation/pages/resize_screen.dart';
import 'package:photo_editor/features/settings/presentation/pages/settings_screen.dart';
import 'package:photo_editor/features/stitching/presentation/pages/stitch_screen.dart';
import 'package:photo_editor/features/watermark/presentation/pages/watermark_screen.dart';
import 'package:photo_editor/features/gallery/presentation/pages/gallery_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Stitch'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.folder_open_outlined),
              tooltip: 'My Work',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GalleryScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Gap(16),
            HeroFeatureCard(
              title: 'Image Stitching',
              subtitle: 'Join screenshots into one long masterpiece',
              icon: Icons.layers, // You might want to use a specific asset here
              gradientStart: const Color(0xFF9D44C0), // Purple from screenshot
              gradientEnd: const Color(0xFF240046), // Darker purple
              isPopular: true,
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
            const Gap(32),
            const Text(
              "Tools",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Gap(16),
            Column(
              children: [
                ToolCard(
                  title: 'Watermark',
                  subtitle: 'Add branding',
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF3A86FF), // Blue
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WatermarkScreen(),
                        ),
                      );
                    }
                  },
                ),
                const Gap(12),
                ToolCard(
                  title: 'Photo Blender',
                  subtitle: 'Mix images',
                  icon: Icons.blur_linear,
                  iconColor: const Color(0xFF06D6A0), // Green for blender
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OverlayScreen(),
                        ),
                      );
                    }
                  },
                ),
                const Gap(12),
                ToolCard(
                  title: 'Markup',
                  subtitle: 'Draw & annotate',
                  icon: Icons.edit_outlined,
                  iconColor: const Color(0xFFFFBE0B), // Yellow/Orange
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
                const Gap(12),
                ToolCard(
                  title: 'Crop & Rotate',
                  subtitle: 'Adjust layout',
                  icon: Icons.crop,
                  iconColor: const Color(0xFFFF006E), // Pink
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CropScreen(),
                        ),
                      );
                    }
                  },
                ),
                const Gap(12),
                ToolCard(
                  title: 'Resize',
                  subtitle: 'Change dimensions',
                  icon: Icons.aspect_ratio,
                  iconColor: const Color(0xFF8338EC), // Purple
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
                const Gap(30), // Bottom padding
              ],
            ),
          ],
        ),
      ),
    );
  }
}
