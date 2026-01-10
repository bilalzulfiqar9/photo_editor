import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/crop/presentation/cubit/crop_cubit.dart';
import 'package:photo_editor/features/crop/presentation/cubit/crop_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<CropCubit>();
        cubit.pickImage();
        return cubit;
      },
      child: BlocConsumer<CropCubit, CropState>(
        listener: (context, state) {
          if (state is CropSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to ${state.result.path}')),
            );
            Navigator.pop(context);
          } else if (state is CropError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is CropReady) {
            return ProImageEditor.file(
              state.file,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (bytes) async {
                  context.read<CropCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is CropSaving) {
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
