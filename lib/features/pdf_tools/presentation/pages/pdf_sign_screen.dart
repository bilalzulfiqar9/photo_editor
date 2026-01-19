import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfSignScreen extends StatefulWidget {
  const PdfSignScreen({super.key});

  @override
  State<PdfSignScreen> createState() => _PdfSignScreenState();
}

class _PdfSignScreenState extends State<PdfSignScreen> {
  File? _pdfFile;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveSignedPdf({bool share = false}) async {
    if (_pdfFile == null) return;

    // MOCK IMPLEMENTATION: Just copies the original file with a new name
    // Real implementation would require a PDF viewer + Signature Pad + PDF compositing
    try {
      final output = await getApplicationDocumentsDirectory();
      final newFile = File(
        '${output.path}/signed_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await _pdfFile!.copy(newFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed PDF Saved to Gallery!'),
            action: share
                ? null
                : SnackBarAction(
                    label: 'Share',
                    onPressed: () => Share.shareXFiles([XFile(newFile.path)]),
                  ),
          ),
        );
        if (share) {
          Share.shareXFiles([XFile(newFile.path)]);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _pdfFile == null
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
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Colors.green,
                        ),
                        const Gap(16),
                        Text(
                          "PDF Selected: ${_pdfFile!.path.split('/').last}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Gap(24),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _pdfFile = null);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            "Remove PDF",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_pdfFile != null)
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
                        onPressed: () => _saveSignedPdf(share: true),
                        icon: const Icon(Icons.share),
                        label: const Text("Share Signed PDF"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black, // Distinction
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _saveSignedPdf(share: false),
                        icon: const Icon(Icons.save_alt),
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
