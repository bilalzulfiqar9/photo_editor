import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:photo_editor/features/pdf_tools/presentation/widgets/signature_pad.dart';

class PdfPageSigner extends StatefulWidget {
  final Uint8List pageImage;

  const PdfPageSigner({super.key, required this.pageImage});

  @override
  State<PdfPageSigner> createState() => _PdfPageSignerState();
}

class _PdfPageSignerState extends State<PdfPageSigner> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  Uint8List? _signatureImage;
  final GlobalKey _imageKey = GlobalKey();

  Future<void> _addSignature() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignaturePad(
          onCancel: () => Navigator.pop(context),
          onConfirm: (ByteData? signature) {
            if (signature != null) {
              setState(() {
                _signatureImage = signature.buffer.asUint8List();
                notifier.value = Matrix4.identity(); // Reset position
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveSignedPage() async {
    if (_signatureImage == null) {
      Navigator.pop(context, widget.pageImage);
      return;
    }

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Decode the background image
      final ui.Image bgImage = await decodeImageFromList(widget.pageImage);

      // Draw white background first to handle transparency
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          bgImage.width.toDouble(),
          bgImage.height.toDouble(),
        ),
        Paint()..color = Colors.white,
      );

      // Draw background image
      canvas.drawImage(bgImage, Offset.zero, Paint());

      // Draw signature with transformations
      // We need to map the screen coordinates of the signature to the image coordinates
      // This is complex because the display image might be scaled to fit the screen.
      // For simplicity in this first pass, we will just capture the widget stack as an image
      // if possible, BUT that lowers resolution.

      // Better approach:
      // 1. Calculate the scale factor between the rendered image size and actual image size.
      // 2. Apply the matrix transformation to the signature.

      // Let's try capturing the RenderRepaintBoundary of the Stack.
      // It allows us to save exactly what is seen, but we need ensuring resolution is good.
      // Since we display the page image, we should try to render at 1x or higher pixel ratio.

      // Wait for the end of the frame to capture
      // Actually, since we have the Matrix, we can composite manually for best quality.

      final ui.Image sigImage = await decodeImageFromList(_signatureImage!);

      // Calculate scale of displayed image vs actual image
      final RenderBox renderBox =
          _imageKey.currentContext!.findRenderObject() as RenderBox;
      final Size displayedSize = renderBox.size;
      final double scaleX = bgImage.width / displayedSize.width;
      final double scaleY = bgImage.height / displayedSize.height;

      // The matrix from the detector is relative to the widget size (displayedSize)
      // We need to scale the translation components of the matrix

      final Matrix4 matrix = notifier.value;

      // Draw signature
      canvas.save();
      // Apply scaling to match the resolution difference
      canvas.scale(scaleX, scaleY);
      // Apply the user-manipulated matrix
      canvas.transform(matrix.storage);

      // The signature is drawn at (0,0) of the transformed space.
      // We might want to center it initially or adjust based on how it's displayed.
      // When added, it's usually centered in the view.

      // Center the signature in the view if no matrix applied?
      // The MatrixGestureDetector wraps the signature widget.
      // If the signature widget is centered, the matrix applies delta from there.

      // Let's simplify: Use ScreenshotController or RepaintBoundary for now to get "what you see"
      // BUT, that limits resolution to screen density. PDF pages can be large.
      // To preserve high quality text (which is already lost as we are using raster images),
      // we just want to preserve the resolution of the rasterized page.

      // Let's stick to RepaintBoundary for simplicity of implementation first,
      // as manual matrix mapping can be error prone with different aspect ratios.
      // If quality is low, we can refine.
      // Wait... we can't use RepaintBoundary easily inside a method without context/build.

      // Alternative: Just return the matrix and signature to the parent,
      // and let the parent handle compositing? No, keep it self-contained.

      // Revised compositing logic:
      canvas.restore(); // Undo the scale/transform for a moment

      // Re-approach: Draw background. Then determine where signature is relative to background.
      // The matrix gives us translation/scale/rotation relative to the container.
      // Transform logic:
      // 1. Scale canvas to match image coordinate system
      // 2. Apply matrix (adjusted for scale)
      // 3. Draw signature image

      canvas.save();
      canvas.scale(scaleX, scaleY); // Scale drawing context to image size
      canvas.transform(matrix.storage); // Apply gesture transform

      // Center the signature?
      // In the UI, the signature is inside a Container that might be centered.
      // We'll see how `MatrixGestureDetector` behaves. Usually it applies transform to child.

      // If the child is the Signature Image, we draw it.
      canvas.drawImage(sigImage, Offset.zero, Paint());
      canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(bgImage.width, bgImage.height);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes != null) {
        Navigator.pop(context, pngBytes.buffer.asUint8List());
      } else {
        Navigator.pop(context, widget.pageImage);
      }
    } catch (e) {
      debugPrint("Error saving: $e");
      Navigator.pop(context, widget.pageImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Sign Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveSignedPage),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Page Image
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: Colors
                          .white, // Add white background for transparent PDFs
                      child: Image.memory(
                        widget.pageImage,
                        key: _imageKey,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
                // Signature Layer
                if (_signatureImage != null)
                  MatrixGestureDetector(
                    onMatrixUpdate: (m, tm, sm, rm) {
                      notifier.value = m;
                    },
                    child: AnimatedBuilder(
                      animation: notifier,
                      builder: (ctx, child) {
                        return Transform(
                          transform: notifier.value,
                          child: Align(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.memory(
                                _signatureImage!,
                                width: 200, // Initial width
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_signatureImage != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _signatureImage = null;
                          notifier.value = Matrix4.identity();
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  FilledButton.icon(
                    onPressed: _addSignature,
                    icon: const Icon(Icons.draw),
                    label: Text(
                      _signatureImage == null ? "Add Signature" : "Redraw",
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
