import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';

class PngToPdfScreen extends StatefulWidget {
  const PngToPdfScreen({super.key});

  @override
  State<PngToPdfScreen> createState() => _PngToPdfScreenState();
}

class _PngToPdfScreenState extends State<PngToPdfScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isGenerating = false;

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _generatePdf({bool share = false}) async {
    if (_images.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final pdf = pw.Document();

      for (var imageFile in _images) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
      }

      final output = await getApplicationDocumentsDirectory();
      final file = File(
        '${output.path}/png_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        setState(() => _isGenerating = false);
        GallerySaverHelper.shouldReloadGallery.value++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF Saved to Gallery!'),
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
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: const Text(
          'PNG -> PDF',
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
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 64,
                          color: Colors.grey.shade600,
                        ),
                        const Gap(16),
                        Text(
                          "Select PNGs to convert",
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        const Gap(24),
                        FilledButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text("Pick PNGs"),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _images.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _images.removeAt(oldIndex);
                        _images.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final file = _images[index];
                      return Card(
                        key: ValueKey(file.path),
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text("Image ${index + 1}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_images.isNotEmpty)
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add),
                            label: const Text("Add More"),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _generatePdf(share: true),
                            icon: const Icon(Icons.share),
                            label: const Text("Share"),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black, // Distinction
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isGenerating
                            ? null
                            : () => _generatePdf(share: false),
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
