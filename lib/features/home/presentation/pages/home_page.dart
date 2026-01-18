import 'package:flutter/material.dart';

import 'package:photo_editor/core/presentation/widgets/evoke_tool_card.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                "Create & Edit",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
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
              childAspectRatio: 1.4,
              children: [
                EvokeToolCard(
                  title: 'Stitch',
                  subtitle: 'Combine screens',
                  icon: Icons.layers,
                  gradient: const [Color(0xFF9681EB), Color(0xFF7A67F5)],
                  isNew: true,
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/stitch');
                    }
                  },
                ),
                EvokeToolCard(
                  title: 'Photo Studio',
                  subtitle: 'Edit, Markup, Crop',
                  icon: Icons.brush_outlined,
                  gradient: const [Color(0xFF00E676), Color(0xFF1DE9B6)],
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/studio');
                    }
                  },
                ),
                EvokeToolCard(
                  title: 'Web Capture',
                  subtitle: 'Website to Image',
                  icon: Icons.public, // Changed icon to public/globe
                  gradient: const [
                    Color(0xFF2193b0),
                    Color(0xFF6dd5ed),
                  ], // Blue/Cyan
                  onTap: () async {
                    context.push('/web-capture');
                  },
                ),
                EvokeToolCard(
                  title: 'Resize',
                  subtitle: 'New dimensions',
                  icon: Icons.aspect_ratio,
                  gradient: const [
                    Color(0xFFFFA000),
                    Color(0xFFFFC107),
                  ], // Orange/Yellow
                  onTap: () async {
                    if (await PermissionHelper.requestStoragePermission()) {
                      context.push('/resize');
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
