import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_editor/features/home/presentation/pages/main_wrapper.dart';
import 'package:photo_editor/features/home/presentation/pages/home_page.dart';
import 'package:photo_editor/features/home/presentation/pages/conversion_tools_screen.dart';

import 'package:photo_editor/features/payment/presentation/pages/subscription_screen.dart';

import 'package:photo_editor/features/gallery/presentation/pages/gallery_screen.dart';
import 'package:photo_editor/features/settings/presentation/pages/settings_screen.dart';
import 'package:photo_editor/features/pdf_tools/presentation/pages/image_to_pdf_screen.dart';
import 'package:photo_editor/features/compression/presentation/pages/image_compress_screen.dart';
import 'package:photo_editor/features/stitching/presentation/pages/stitch_screen.dart';
import 'package:photo_editor/features/markup/presentation/pages/markup_screen.dart';
import 'package:photo_editor/features/watermark/presentation/pages/watermark_screen.dart';
import 'package:photo_editor/features/overlay/presentation/pages/overlay_screen.dart';
import 'package:photo_editor/features/crop/presentation/pages/crop_screen.dart';
import 'package:photo_editor/features/resize/presentation/pages/resize_screen.dart';
import 'package:photo_editor/features/converter/presentation/pages/png_to_svg_screen.dart';
import 'package:photo_editor/features/pdf_tools/presentation/pages/png_to_pdf_screen.dart';
import 'package:photo_editor/features/pdf_tools/presentation/pages/pdf_sign_screen.dart';
import 'package:photo_editor/features/pro/presentation/pages/pro_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
            ],
          ),
          // Branch 2: Conversion
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/convert',
                builder: (context, state) => const ConversionToolsScreen(),
              ),
            ],
          ),
          // Branch 3: Gallery
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                builder: (context, state) => const GalleryScreen(),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/image-to-pdf',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ImageToPdfScreen(),
      ),
      GoRoute(
        path: '/image-compress',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ImageCompressScreen(),
      ),
      GoRoute(
        path: '/stitch',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StitchScreen(),
      ),
      GoRoute(
        path: '/markup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MarkupScreen(),
      ),
      GoRoute(
        path: '/watermark',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WatermarkScreen(),
      ),
      GoRoute(
        path: '/overlay',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OverlayScreen(),
      ),
      GoRoute(
        path: '/crop',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CropScreen(),
      ),
      GoRoute(
        path: '/resize',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ResizeScreen(),
      ),
      GoRoute(
        path: '/png-to-svg',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PngToSvgScreen(),
      ),
      GoRoute(
        path: '/png-to-pdf',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PngToPdfScreen(),
      ),
      GoRoute(
        path: '/pdf-sign',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PdfSignScreen(),
      ),
      GoRoute(
        path: '/pro',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProScreen(),
      ),
    ],
  );
}
