import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generatePdfBytes(List<Uint8List> images) async {
  final doc = pw.Document();

  for (final imageBytes in images) {
    final image = pw.MemoryImage(imageBytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
        margin: pw.EdgeInsets.zero, // Full page image
      ),
    );
  }
  return doc.save();
}
