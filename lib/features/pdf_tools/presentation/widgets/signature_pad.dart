import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class SignaturePad extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<ByteData?> onConfirm;

  const SignaturePad({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final HandSignatureControl control = HandSignatureControl(
    threshold: 0.01,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: widget.onCancel,
        ),
        title: const Text(
          'Draw Signature',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () async {
              if (control.paths.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please draw a signature first'),
                  ),
                );
                return;
              }
              final svg = control.toSvg(
                color: Colors.black,
                type: SignatureDrawType.shape,
                fit: true,
              );

              final image = await control.toImage(
                color: Colors.black,
                background: Colors.transparent,
                fit: true,
              );

              widget.onConfirm(image);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                // Ensure the gesture detector captures touches by having a transparent background or simply filling the area
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: HandSignature(
                    control: control,
                    color: Colors.black,
                    width: 2.0, // Minimum stroke width
                    maxWidth: 4.0, // Maximum stroke width
                    type: SignatureDrawType.shape,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => control.clear(),
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
