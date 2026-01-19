import 'package:flutter/material.dart';

import 'package:photo_editor/core/router/app_router.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

import 'features/payment/presentation/cubit/payment_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => di.sl<PaymentCubit>())],
      child: MaterialApp.router(
        title: 'Photo Editor & Stitcher',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
