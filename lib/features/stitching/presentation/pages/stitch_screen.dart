import 'dart:io';
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (images.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 80,
                              color: Colors.grey[800],
                            ),
                            const Gap(16),
                            const Text(
                              "No images selected",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: images.length,
                        onReorder: (oldIndex, newIndex) => context
                            .read<StitchCubit>()
                            .reorderImages(oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          return Card(
                            key: ValueKey(images[index].path),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Image.file(
                                images[index],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text("Image ${index + 1}"),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => context
                                    .read<StitchCubit>()
                                    .removeImage(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.read<StitchCubit>().pickImages(),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text("Add Images"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      if (images.length >= 2) ...[
                        const Gap(16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.read<StitchCubit>().stitch(),
                            icon: const Icon(Icons.merge_type),
                            label: const Text("Stitch"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
          child: SingleChildScrollView(
            child: InteractiveViewer(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(result),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  context.read<StitchCubit>().reset();
                },
                icon: const Icon(Icons.refresh),
                tooltip: "Reset",
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Share or save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saving not implemented yet")),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
