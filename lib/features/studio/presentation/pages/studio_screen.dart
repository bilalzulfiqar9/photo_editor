import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/features/studio/presentation/cubit/studio_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_editor/features/payment/presentation/cubit/payment_cubit.dart';
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
            // Already handled by builder to show success UI.
            // Delay popping to let user see "Saved!" message.
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            });
          } else if (state is StudioError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  final isPremium = await context
                      .read<PaymentCubit>()
                      .isPremium;
                  if (!isPremium) {
                    context.push('/pro');
                    return;
                  }
                  context.read<StudioCubit>().save(bytes);
                },
                onCloseEditor: (_) {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is StudioSaving) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Saving...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          } else if (state is StudioSaved) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text("Saved!", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }

          return const Scaffold(
            backgroundColor: Colors.black, // Dark background while loading
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        },
      ),
    );
  }
}
