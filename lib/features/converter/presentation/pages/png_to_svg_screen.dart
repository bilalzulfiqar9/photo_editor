import 'dart:io';
import 'dart:convert';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';

class PngToSvgScreen extends StatefulWidget {
  const PngToSvgScreen({super.key});

  @override
  State<PngToSvgScreen> createState() => _PngToSvgScreenState();
}

class _PngToSvgScreenState extends State<PngToSvgScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isGenerating = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _generateSvg({bool share = false}) async {
    if (_image == null) return;

    setState(() => _isGenerating = true);

    try {
      // Basic mock implementation: Embeds image in SVG as base64
      // This is a common way to "convert" non-vector images to SVG format,
      // though it remains raster content. A full vectorizer is complex.
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final decodedImage = await decodeImageFromList(bytes);

      final svgContent =
          '''
<svg width="${decodedImage.width}" height="${decodedImage.height}" xmlns="http://www.w3.org/2000/svg">
  <image href="data:image/png;base64,$base64Image" width="${decodedImage.width}" height="${decodedImage.height}" />
</svg>
''';

      final output = await getApplicationDocumentsDirectory();
      final file = File(
        '${output.path}/png_to_svg_${DateTime.now().millisecondsSinceEpoch}.svg',
      );
      await file.writeAsString(svgContent);

      if (mounted) {
        setState(() => _isGenerating = false);
        GallerySaverHelper.shouldReloadGallery.value++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('SVG Saved to Gallery!'),
            action: share
                ? null
                : SnackBarAction(
                    label: 'Share',
                    onPressed: () => Share.shareXFiles([XFile(file.path)]),
                  ),
          ),
        );
        if (share) {
          Share.shareXFiles([XFile(file.path)]);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating SVG: $e')));
      }
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: const Text(
          'PNG -> SVG',
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
      ),
      body: Column(
        children: [
          Expanded(
            child: _image == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.grey.shade600,
                        ),
                        const Gap(16),
                        Text(
                          "Select a PNG to convert",
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        const Gap(24),
                        FilledButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text("Pick PNG"),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!),
                          ),
                          const Gap(20),
                          TextButton.icon(
                            onPressed: _removeImage,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              "Remove Image",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (_image != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isGenerating
                            ? null
                            : () => _generateSvg(share: true),
                        icon: const Icon(Icons.share),
                        label: const Text("Share SVG"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isGenerating
                            ? null
                            : () => _generateSvg(share: false),
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_alt),
                        label: const Text("Save locally"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
