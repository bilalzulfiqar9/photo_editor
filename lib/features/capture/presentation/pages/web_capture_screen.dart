import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:photo_editor/features/studio/presentation/pages/studio_screen.dart';

class WebCaptureScreen extends StatefulWidget {
  const WebCaptureScreen({super.key});

  @override
  State<WebCaptureScreen> createState() => _WebCaptureScreenState();
}

class _WebCaptureScreenState extends State<WebCaptureScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  Future<void> _captureVisible() async {
    setState(() => _isLoading = true);
    try {
      // NOTE: Screenshotting a WebView (Platform View) is tricky.
      // 1. screenshot package: Works well on Android, issues on iOS sometimes because of platform view composite.
      // 2. _controller.takeScreenshot() isn't native to this package without extensions.
      // Trying standard screenshot widget first.

      final Uint8List? capturedImage = await _screenshotController.capture();

      if (capturedImage != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/web_capture_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(capturedImage);

        if (!mounted) return;

        // Navigate to Studio Screen with the captured file
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudioScreen(initialImage: file),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to capture screenshot")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error capturing: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'Enter URL',
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                final url = _urlController.text;
                if (url.isNotEmpty) {
                  _controller.loadRequest(
                    Uri.parse(url.startsWith('http') ? url : 'https://$url'),
                  );
                }
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isLoading ? null : _captureVisible,
          ),
        ],
      ),
      body: Stack(
        children: [
          Screenshot(
            controller: _screenshotController,
            // WebViewWidget is a platform view. Screenshot package v2 might struggle
            // without specific flutter render flags or on iOS.
            // But let's try this standard approach first.
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
