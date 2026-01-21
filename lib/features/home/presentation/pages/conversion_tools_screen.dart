import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:photo_editor/core/presentation/widgets/evoke_tool_card.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';

class ConversionToolsScreen extends StatelessWidget {
  const ConversionToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'Screen Stitch',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Text(
                "Your imagination, powered by Utility",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4, // Matches HomePage compactness
              children: [
                EvokeToolCard(
                  title: 'PNG -> SVG',
                  subtitle: 'Vectorize cleanly',
                  icon: Icons.image,
                  gradient: const [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ], // Purple/Blue
                  isNew: true,
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/png-to-svg');
                    }
                  },
                ),
                EvokeToolCard(
                  title: 'PNG -> PDF',
                  subtitle: 'Extract frames',
                  icon: Icons.picture_as_pdf,
                  gradient: const [
                    Color(0xFFFF416C),
                    Color(0xFFFF4B2B),
                  ], // Red/Pink
                  badgeText: 'Try',
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/png-to-pdf');
                    }
                  },
                ),
                EvokeToolCard(
                  title: "IMG's -> PDF",
                  subtitle: 'Make one file',
                  icon: Icons.picture_as_pdf,
                  gradient: const [
                    Color(0xFF11998e),
                    Color(0xFF38ef7d),
                  ], // Green
                  badgeText: 'Try',
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/image-to-pdf');
                    }
                  },
                ),
                EvokeToolCard(
                  title: 'PDF -> SIGN',
                  subtitle: 'Make your Sign',
                  icon: Icons.description,
                  gradient: const [
                    Color(0xFF2193b0),
                    Color(0xFF6dd5ed),
                  ], // Blue/Cyan
                  badgeText: 'Try',
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/pdf-sign');
                    }
                  },
                ),
                EvokeToolCard(
                  title: 'Image Compressor',
                  subtitle: 'Compress image',
                  icon: Icons.compress,
                  gradient: const [
                    Color(0xFFF7971E),
                    Color(0xFFFFD200),
                  ], // Orange/Yellow
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/image-compress');
                    }
                  },
                ),
              ],
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}
