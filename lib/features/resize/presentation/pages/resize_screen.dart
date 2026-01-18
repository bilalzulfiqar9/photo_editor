import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gap/gap.dart';

import 'package:photo_editor/features/resize/presentation/cubit/resize_cubit.dart';
import 'package:photo_editor/features/resize/presentation/cubit/resize_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:photo_editor/core/utils/debouncer.dart';

class ResizeScreen extends StatefulWidget {
  const ResizeScreen({super.key});

  @override
  State<ResizeScreen> createState() => _ResizeScreenState();
}

class _ResizeScreenState extends State<ResizeScreen> {
  double _quality = 90;
  int _width = 1080;
  int _height = 1080;
  CompressFormat _selectedFormat = CompressFormat.jpeg;

  TextEditingController _widthController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  bool _initializedFromImage = false;

  final List<int> _presets = [100, 90, 80, 70, 60, 50, 40, 30];

  @override
  void initState() {
    super.initState();
    _widthController.text = '$_width';
    _heightController.text = '$_height';
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResizeCubit>()..pickImage(),
      child: BlocConsumer<ResizeCubit, ResizeState>(
        listener: (context, state) {
          if (state is ResizeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ResizeReady) {
            // Sync initial dimensions if available
            if (!_initializedFromImage &&
                state.originalWidth != null &&
                state.originalHeight != null) {
              _width = state.originalWidth!;
              _height = state.originalHeight!;
              _widthController.text = '$_width';
              _heightController.text = '$_height';
              _initializedFromImage = true;
              // Optional: trigger compress immediately with new dims
              context.read<ResizeCubit>().compressImage(
                quality: _quality.round(),
                format: _selectedFormat,
                width: _width,
                height: _height,
              );
            }
          }
        },
        builder: (context, state) {
          File? displayedImage;
          String sizeInfo = "Select Image";

          if (state is ResizeReady) {
            displayedImage = state.compressedFile ?? state.originalFile;
            final originalKb = (state.originalSize / 1024).toStringAsFixed(1);
            final compressedKb = state.compressedSize != null
                ? (state.compressedSize! / 1024).toStringAsFixed(1)
                : "???";
            sizeInfo = "$originalKb kB -> $compressedKb kB";
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(sizeInfo),
              actions: [
                IconButton(
                  icon: const Icon(Icons.compare_arrows),
                  onPressed: () {
                    // TODO: implement hold-to-compare
                  },
                ),
              ],
            ),
            body: state is ResizeLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedImage == null
                ? Center(
                    child: TextButton.icon(
                      onPressed: () => context.read<ResizeCubit>().pickImage(),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text("Pick Image"),
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state is ResizeReady && state.isCompressing)
                              const LinearProgressIndicator(),
                            const Gap(24),
                            // Image Preview
                            Center(
                              child: Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: FileImage(displayedImage),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(24),

                            // Edit EXIF
                            Center(
                              child: ActionChip(
                                avatar: const Icon(
                                  Icons.discount_outlined,
                                  size: 16,
                                ),
                                label: const Text('Edit EXIF'),
                                onPressed: () {
                                  if (state is ResizeReady) {
                                    _showExifDialog(context, state.exifData);
                                  }
                                },
                              ),
                            ),
                            const Gap(24),

                            // Presets
                            const Text(
                              'Presets',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Gap(12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _presets
                                    .map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: ChoiceChip(
                                          label: Text('$p%'),
                                          selected: _quality == p,
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(
                                                () => _quality = p.toDouble(),
                                              );
                                              _triggerCompress(context);
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const Gap(24),

                            // Dimensions
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _widthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Width',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      _width = int.tryParse(v) ?? _width;
                                      _debouncer.run(
                                        () => _triggerCompress(context),
                                      );
                                    },
                                  ),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: TextField(
                                    controller: _heightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Height',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      _height = int.tryParse(v) ?? _height;
                                      _debouncer.run(
                                        () => _triggerCompress(context),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Gap(24),

                            // Quality Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Quality',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('${_quality.round()}%'),
                              ],
                            ),
                            Slider(
                              value: _quality,
                              min: 1,
                              max: 100,
                              divisions: 100,
                              onChanged: (v) => setState(() => _quality = v),
                              onChangeEnd: (v) => _triggerCompress(context),
                            ),
                            const Gap(24),

                            // Image Format
                            const Text(
                              'Image Format',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Gap(12),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFormatChip(
                                  context,
                                  'JPG',
                                  CompressFormat.jpeg,
                                ),
                                _buildFormatChip(
                                  context,
                                  'PNG',
                                  CompressFormat.png,
                                ),
                                _buildFormatChip(
                                  context,
                                  'WEBP',
                                  CompressFormat.webp,
                                ),
                                _buildFormatChip(
                                  context,
                                  'HEIC',
                                  CompressFormat.heic,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: displayedImage == null
                  ? null
                  : () async {
                      final success = await GallerySaverHelper.saveImage(
                        displayedImage!.path,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Saved to Gallery & App"
                                  : "Failed to save",
                            ),
                          ),
                        );
                      }
                    },
              child: const Icon(Icons.save),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormatChip(
    BuildContext context,
    String label,
    CompressFormat format,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFormat == format,
      onSelected: (v) {
        if (v) {
          setState(() => _selectedFormat = format);
          _triggerCompress(context);
        }
      },
    );
  }

  void _triggerCompress(BuildContext context) {
    context.read<ResizeCubit>().compressImage(
      quality: _quality.round(),
      format: _selectedFormat,
      width: _width,
      height: _height,
    );
  }

  void _showExifDialog(BuildContext context, Map<String, dynamic> exifData) {
    // Define common editable keys
    final editableKeys = [
      'ImageDescription',
      'Copyright',
      'Artist',
      'UserComment',
    ];
    final controllers = <String, TextEditingController>{};

    for (var key in editableKeys) {
      controllers[key] = TextEditingController(
        text: exifData[key]?.toString() ?? '',
      );
    }

    // Also include other keys in the map but maybe not editable?
    // For simplicity, let's just let user add/edit these specific standard ones.

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit EXIF Data"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...editableKeys.map(
                (key) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    controller: controllers[key],
                    decoration: InputDecoration(
                      labelText: key,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final newExif = <String, dynamic>{};
              controllers.forEach((key, controller) {
                if (controller.text.isNotEmpty) {
                  newExif[key] = controller.text;
                }
              });
              context.read<ResizeCubit>().updateExif(newExif);
              // Trigger compress to apply changes to file?
              // If we just update state, it won't write until next compress.
              // We should trigger a compress to save changes to the output file.
              _triggerCompress(context);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
