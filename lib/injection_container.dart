import 'package:get_it/get_it.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Home

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

  // Features - Capture

  // Core
}
