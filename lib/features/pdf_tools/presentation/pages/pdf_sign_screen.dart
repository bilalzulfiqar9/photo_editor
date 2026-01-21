import 'dart:io';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_editor/features/pdf_tools/presentation/pages/pdf_page_signer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_editor/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:flutter/foundation.dart'; // for compute
import 'package:photo_editor/features/pdf_tools/presentation/pages/pdf_worker.dart';

class PdfSignScreen extends StatefulWidget {
  const PdfSignScreen({super.key});

  @override
  State<PdfSignScreen> createState() => _PdfSignScreenState();
}

class _PdfSignScreenState extends State<PdfSignScreen> {
  File? _originalPdfFile;
  List<Uint8List> _pageImages = [];
  bool _isLoading = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
        _originalPdfFile = File(result.files.single.path!);
        _pageImages = [];
      });

      try {
        // Rasterize PDF pages to images
        await for (final page in Printing.raster(
          await _originalPdfFile!.readAsBytes(),
          pages: null, // All pages
          dpi: 150, // Standard quality
        )) {
          final imageBytes = await page.toPng();
          setState(() {
            _pageImages.add(imageBytes);
          });
        }
      } catch (e) {
        debugPrint("Error parsing PDF: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error parsing PDF: $e')));
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editPage(int index) async {
    final Uint8List? signedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPageSigner(pageImage: _pageImages[index]),
      ),
    );

    if (signedImage != null) {
      setState(() {
        _pageImages[index] = signedImage;
      });
    }
  }

  Future<void> _saveSignedPdf({bool share = false}) async {
    if (_pageImages.isEmpty) return;

    // Check Premium
    final isPremium = await context.read<PaymentCubit>().isPremium;
    if (!isPremium) {
      context.push('/pro');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Offload PDF generation to a worker isolate
      final pdfBytes = await compute(generatePdfBytes, _pageImages);

      final output = await getApplicationDocumentsDirectory();
      final newFile = File(
        '${output.path}/signed_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await newFile.writeAsBytes(pdfBytes);

      // Save to Public Downloads
      final publicPath = await GallerySaverHelper.saveFileToDownloads(
        newFile.path,
      );

      // Trigger Gallery Update
      GallerySaverHelper.shouldReloadGallery.value++;

      if (mounted) {
        setState(() => _isLoading = false);

        final msg = publicPath != null
            ? 'PDF Saved to Downloads: ${publicPath.split('/').last}'
            : 'Signed PDF Saved!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 4),
            action: share
                ? null
                : SnackBarAction(
                    label: 'Share',
                    onPressed: () =>
                        Share.shareXFiles([XFile(publicPath ?? newFile.path)]),
                  ),
          ),
        );
        if (share) {
          Share.shareXFiles([XFile(publicPath ?? newFile.path)]);
        }
      }
    } catch (e) {
      debugPrint("Error saving PDF: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  void _reset() {
    setState(() {
      _originalPdfFile = null;
      _pageImages = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'PDF -> SIGN',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_pageImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _reset,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pageImages.isEmpty
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
                    "Select a PDF to sign",
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  const Gap(24),
                  FilledButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Pick PDF"),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _pageImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _editPage(index),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Image.memory(
                                _pageImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "Page ${index + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _saveSignedPdf(share: false),
                            icon: const Icon(Icons.save_alt),
                            label: const Text("Save"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _saveSignedPdf(share: true),
                            icon: const Icon(Icons.share),
                            label: const Text("Share"),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
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
