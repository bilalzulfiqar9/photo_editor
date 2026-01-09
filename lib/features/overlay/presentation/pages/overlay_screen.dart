import 'package:flutter/material.dart' hide OverlayState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/overlay/presentation/cubit/overlay_cubit.dart';
import 'package:photo_editor/features/overlay/presentation/cubit/overlay_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<OverlayCubit>();
        cubit.pickImage();
        return cubit;
      },
      child: BlocConsumer<OverlayCubit, OverlayState>(
        listener: (context, state) {
          if (state is OverlaySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to ${state.result.path}')),
            );
            Navigator.pop(context);
          } else if (state is OverlayError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is OverlayReady) {
            return ProImageEditor.file(
              state.file,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (bytes) async {
                  context.read<OverlayCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is OverlaySaving) {
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
