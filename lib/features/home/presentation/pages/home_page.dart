import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';
import 'package:photo_editor/features/home/presentation/widgets/feature_card.dart';
import 'package:photo_editor/features/stitching/presentation/pages/stitch_screen.dart';
import 'package:photo_editor/features/markup/presentation/pages/markup_screen.dart';
import 'package:photo_editor/features/capture/presentation/pages/web_capture_screen.dart';
import 'package:photo_editor/features/gallery/presentation/pages/gallery_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Text(
                'Photo\nToolkit',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const Gap(10),
              Text(
                'Create, Stitch & Edit like a Pro',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const Gap(40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    FeatureCard(
                      title: 'Stitch Photos',
                      description: 'Merge screenshots vertically',
                      icon: Icons.layers_outlined,
                      color: const Color(0xFF6C63FF),
                      onTap: () async {
                        // Request permission first
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
                    FeatureCard(
                      title: 'Photo Markup',
                      description: 'Annotate & draw on images',
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF03DAC6),
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
                    FeatureCard(
                      title: 'Web Capture',
                      description: 'Capture full websites',
                      icon: Icons.camera_alt_outlined,
                      color: const Color(0xFFFF4081),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebCaptureScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'My Gallery',
                      description: 'View your creations',
                      icon: Icons.photo_library_outlined,
                      color: const Color(0xFFFFB74D),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GalleryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
