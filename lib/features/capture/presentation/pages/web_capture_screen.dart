import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  Future<void> _captureVisible() async {
    // Note: This only captures the visible viewport in many compiled webview implementations due to platform limitations.
    // However, it's a good "Capture" feature for now.
    // For full page, we'd need more complex JS injection.

    // Actually, webview_flutter doesn't have a direct "takeScreenshot" method exposed easily in all versions without platform views.
    // But let's assume standard usage or standard boundary repaint if possible?
    // WebView is a platform view, RepaintBoundary might not work perfectly on all Flutter versions for it.
    // Let's try native controller method if available or a workaround.
    // In strict mode, we might just skip the capture and let user know "Functionality limited".

    // BUT, I want to WOW.
    // Let's use a workaround: The user will likely use system screenshot, but I can offer "Edit Last Screenshot" if I could access gallery.

    // Let's just try to Navigate to Markup with a dummy valid file for now or implement file picking if this fails.
    // Wait, I can't easily capture WebView pixels in Flutter without native code.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Capture coming soon! Use system screenshot then Stitch.",
        ),
      ),
    );
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
            onPressed: _captureVisible,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
