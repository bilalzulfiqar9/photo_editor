import 'dart:io';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';

class ImageCompressScreen extends StatefulWidget {
  const ImageCompressScreen({super.key});

  @override
  State<ImageCompressScreen> createState() => _ImageCompressScreenState();
}

class _ImageCompressScreenState extends State<ImageCompressScreen> {
  File? _originalImage;
  File? _compressedImage;
  int _quality = 80;
  bool _isCompressing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _originalImage = File(pickedFile.path);
        _compressedImage = null; // Reset previous result
      });
    }
  }

  Future<void> _compressImage() async {
    if (_originalImage == null) return;

    setState(() => _isCompressing = true);

    try {
      final tmpDir = await getTemporaryDirectory();
      final targetPath =
          '${tmpDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        _originalImage!.absolute.path,
        targetPath,
        quality: _quality, // Quality usually applies to JPEG
      );

      if (result != null) {
        setState(() {
          _compressedImage = File(result.path);
          _isCompressing = false;
        });
      } else {
        setState(() => _isCompressing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Compression failed or format not supported"),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isCompressing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Compressor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_originalImage == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const Gap(8),
                      Text(
                        "Tap to select image",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Comparison View
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Original",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _originalImage!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Gap(4),
                            Text(_getFileSize(_originalImage!)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Result",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(8),
                            if (_compressedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _compressedImage!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(child: Text("?")),
                              ),
                            const Gap(4),
                            if (_compressedImage != null)
                              Text(
                                _getFileSize(_compressedImage!),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(32),
                  const Text("Quality"),
                  Slider(
                    value: _quality.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: "$_quality%",
                    onChanged: (v) {
                      setState(() {
                        _quality = v.toInt();
                        _compressedImage = null; // Invalidate previous result
                      });
                    },
                  ),
                  const Gap(32),

                  if (_isCompressing)
                    const CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        if (_compressedImage == null)
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _compressImage,
                              icon: const Icon(Icons.compress),
                              label: const Text("Compress Now"),
                            ),
                          ),
                        if (_compressedImage != null) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _originalImage = null;
                                  _compressedImage = null;
                                });
                                _pickImage();
                              },
                              child: const Text("New"),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final success =
                                    await GallerySaverHelper.saveImage(
                                      _compressedImage!.path,
                                    );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Saved to Gallery"
                                            : "Failed to save",
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Save"),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Share.shareXFiles([
                                XFile(_compressedImage!.path),
                              ]),
                              icon: const Icon(Icons.share),
                              label: const Text("Share"),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
