import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/markup/presentation/cubit/markup_cubit.dart';
import 'package:photo_editor/features/markup/presentation/cubit/markup_state.dart';
import 'package:photo_editor/injection_container.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class MarkupScreen extends StatelessWidget {
  final File? initialImage;

  const MarkupScreen({super.key, this.initialImage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<MarkupCubit>();
        if (initialImage != null) {
          cubit.loadImage(initialImage!);
        } else {
          cubit.pickImage();
        }
        return cubit;
      },
      child: BlocConsumer<MarkupCubit, MarkupState>(
        listener: (context, state) {
          if (state is MarkupSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved to ${state.result.path}')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is MarkupReady) {
            return ProImageEditor.file(
              state.file,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (bytes) async {
                  context.read<MarkupCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is MarkupSaving) {
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
