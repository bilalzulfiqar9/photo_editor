import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gap/gap.dart';

import 'package:photo_editor/features/resize/presentation/cubit/resize_cubit.dart';
import 'package:photo_editor/features/resize/presentation/cubit/resize_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';

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

  final List<int> _presets = [100, 90, 80, 70, 60, 50, 40, 30];

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
            // Update logic if needed when new state arrives
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              // TODO: Show EXIF Dialog
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
                                    padding: const EdgeInsets.only(right: 8.0),
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
                                decoration: const InputDecoration(
                                  labelText: 'Width',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  _width = int.tryParse(v) ?? _width;
                                  _triggerCompress(context);
                                },
                                controller: TextEditingController(
                                  text: '$_width',
                                ),
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  _height = int.tryParse(v) ?? _height;
                                  _triggerCompress(context);
                                },
                                controller: TextEditingController(
                                  text: '$_height',
                                ),
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
}
