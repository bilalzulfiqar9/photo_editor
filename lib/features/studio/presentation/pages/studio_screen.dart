import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/studio/presentation/cubit/studio_cubit.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class StudioScreen extends StatelessWidget {
  final File? initialImage;

  const StudioScreen({super.key, this.initialImage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<StudioCubit>();
        if (initialImage != null) {
          cubit.loadImage(initialImage!);
        } else {
          cubit.pickImage();
        }
        return cubit;
      },
      child: BlocConsumer<StudioCubit, StudioState>(
        listener: (context, state) {
          if (state is StudioSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Image Saved to Gallery!')));
            Navigator.pop(context);
          } else if (state is StudioError) {
            // If cancel or error, just go back
            if (state.message == "No image selected") {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        builder: (context, state) {
          if (state is StudioReady) {
            return ProImageEditor.file(
              state.file,
              configs: const ProImageEditorConfigs(
                designMode: ImageEditorDesignMode.material,
                // Enable everything by default for "Studio" experience
              ),
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (bytes) async {
                  context.read<StudioCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is StudioSaving) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return const Scaffold(
            backgroundColor: Colors.black, // Dark background while loading
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
