import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_editor/features/stitching/domain/repositories/stitching_repository.dart';
import 'features/stitching/presentation/cubit/stitch_cubit.dart';
import 'features/stitching/domain/usecases/stitch_images_usecase.dart';
import 'features/stitching/data/repositories/stitching_repository_impl.dart';
import 'features/stitching/data/datasources/stitching_data_source.dart';
import 'features/markup/data/datasources/markup_data_source.dart';
import 'features/markup/data/repositories/markup_repository_impl.dart';
import 'features/markup/domain/repositories/markup_repository.dart';
import 'features/markup/domain/usecases/save_image_usecase.dart';
import 'features/markup/presentation/cubit/markup_cubit.dart';
import 'features/resize/data/datasources/resize_data_source.dart';
import 'features/resize/data/repositories/resize_repository_impl.dart';
import 'features/resize/domain/repositories/resize_repository.dart';
import 'features/resize/presentation/cubit/resize_cubit.dart';
import 'features/watermark/data/repositories/watermark_repository_impl.dart';
import 'features/watermark/domain/repositories/watermark_repository.dart';
import 'features/watermark/domain/usecases/save_watermark_usecase.dart';
import 'features/watermark/presentation/cubit/watermark_cubit.dart';
import 'features/crop/data/repositories/crop_repository_impl.dart';
import 'features/crop/domain/repositories/crop_repository.dart';
import 'features/crop/domain/usecases/save_crop_usecase.dart';
import 'features/crop/presentation/cubit/crop_cubit.dart';
import 'features/overlay/data/repositories/overlay_repository_impl.dart';
import 'features/overlay/domain/repositories/overlay_repository.dart';
import 'features/overlay/domain/usecases/save_overlay_usecase.dart';
import 'features/overlay/presentation/cubit/overlay_cubit.dart';
import 'features/payment/data/datasources/stripe_service.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

import 'features/auth/data/datasources/firebase_auth_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core

  // Features - Auth
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);

  sl.registerFactory(
    () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signInAnonymouslyUseCase: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInAnonymouslyUseCase(sl()));

  // Features - Payment
  sl.registerFactory(() => PaymentCubit(sl()));
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => StripeService());

  // Features - Stitching

  sl.registerFactory(() => StitchCubit(sl()));
  sl.registerLazySingleton(() => StitchImagesUseCase(sl()));
  sl.registerLazySingleton<StitchingRepository>(
    () => StitchingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<StitchingDataSource>(
    () => StitchingDataSourceImpl(),
  );

  // Features - Markup
  sl.registerFactory(() => MarkupCubit(sl()));
  sl.registerLazySingleton(() => SaveImageUseCase(sl()));
  sl.registerLazySingleton<MarkupRepository>(() => MarkupRepositoryImpl(sl()));
  sl.registerLazySingleton<MarkupDataSource>(() => MarkupDataSourceImpl());

  // Features - Resize
  sl.registerFactory(() => ResizeCubit(sl()));
  sl.registerLazySingleton<ResizeRepository>(() => ResizeRepositoryImpl(sl()));
  sl.registerLazySingleton<ResizeDataSource>(() => ResizeDataSourceImpl());

  // Features - Watermark
  sl.registerFactory(() => WatermarkCubit(sl()));
  sl.registerLazySingleton(() => SaveWatermarkUseCase(sl()));
  sl.registerLazySingleton<WatermarkRepository>(
    () => WatermarkRepositoryImpl(),
  );

  // Features - Crop
  sl.registerFactory(() => CropCubit(sl()));
  sl.registerLazySingleton(() => SaveCropUseCase(sl()));
  sl.registerLazySingleton<CropRepository>(() => CropRepositoryImpl());

  // Features - Overlay
  sl.registerFactory(() => OverlayCubit(sl()));
  sl.registerLazySingleton(() => SaveOverlayUseCase(sl()));
  sl.registerLazySingleton<OverlayRepository>(() => OverlayRepositoryImpl());
}
