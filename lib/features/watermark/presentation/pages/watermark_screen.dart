import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/watermark/presentation/cubit/watermark_cubit.dart';
import 'package:photo_editor/features/watermark/presentation/cubit/watermark_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class WatermarkScreen extends StatelessWidget {
  const WatermarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<WatermarkCubit>();
        cubit.pickImage();
        return cubit;
      },
      child: BlocConsumer<WatermarkCubit, WatermarkState>(
        listener: (context, state) {
          if (state is WatermarkSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Watermark saved to ${state.result.path}'),
              ),
            );
            Navigator.pop(context);
          } else if (state is WatermarkError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context); // Exit if image pick fails or other error
          }
        },
        builder: (context, state) {
          if (state is WatermarkReady) {
            return ProImageEditor.file(
              state.file,
              configs: ProImageEditorConfigs(
                designMode: ImageEditorDesignModeE.material,
                imageGeneration: const ImageGenerationConfigs(
                  generateInsideSeparateThread: true,
                  generateImageInBackground: true,
                ),
                mainEditor: const MainEditorConfigs(enableCloseButton: true),
                paintEditor: const PaintEditorConfigs(enabled: false),
                cropRotateEditor: const CropRotateEditorConfigs(
                  enabled: false,
                ), // Disable Crop for Watermark
                filterEditor: const FilterEditorConfigs(
                  enabled: false,
                ), // Disable Filters
                blurEditor: const BlurEditorConfigs(
                  enabled: false,
                ), // Disable Blur
                emojiEditor: const EmojiEditorConfigs(
                  enabled: true,
                ), // Enable Stickers
                textEditor: const TextEditorConfigs(
                  enabled: true,
                ), // Enable Text
              ),
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (bytes) async {
                  context.read<WatermarkCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is WatermarkSaving) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
