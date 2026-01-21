import 'dart:io';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:photo_editor/features/stitching/presentation/cubit/stitch_cubit.dart';
import 'package:photo_editor/features/stitching/presentation/cubit/stitch_state.dart';
import 'package:photo_editor/injection_container.dart';

class StitchScreen extends StatelessWidget {
  const StitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StitchCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Stitch Photos')),
        body: BlocConsumer<StitchCubit, StitchState>(
          listener: (context, state) {
            if (state is StitchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is StitchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StitchLoaded) {
              return _buildResultView(context, state.result);
            }

            // Initial or Selection Update
            final images = (state is ImageSelectionUpdate)
                ? state.selectedImages
                : <File>[];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (images.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 60,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Gap(24),
                            const Text(
                              "No images selected",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            const Gap(32),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<StitchCubit>().pickImages(),
                              icon: const Icon(Icons.add),
                              label: const Text("Select Images"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${images.length} Images",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      context.read<StitchCubit>().pickImages(),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text("Add More"),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ReorderableListView.builder(
                              itemCount: images.length,
                              onReorder: (oldIndex, newIndex) => context
                                  .read<StitchCubit>()
                                  .reorderImages(oldIndex, newIndex),
                              itemBuilder: (context, index) {
                                return Container(
                                  key: ValueKey(images[index].path),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        images[index],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        cacheWidth: 150,
                                      ),
                                    ),
                                    title: Text(
                                      "Image ${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.drag_handle,
                                          color: Colors.grey,
                                        ),
                                        const Gap(8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => context
                                              .read<StitchCubit>()
                                              .removeImage(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (images.length >= 2) ...[
                    const Gap(20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.read<StitchCubit>().stitch(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Stitch Images",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, File result) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 4.0,
                child: Center(child: Image.file(result)),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<StitchCubit>().reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Start Over"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await GallerySaverHelper.saveImage(
                      result.path,
                    );
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Saved to Gallery")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to save to Gallery"),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save_alt),
                  label: const Text("Save to Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
