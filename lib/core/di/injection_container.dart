import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/data/datasources/courses_asset_datasource.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/presentation/cubit/courses_cubit.dart';

import '../../features/progress/data/datasources/progress_local_datasource.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/progress/domain/services/progress_service.dart';

import '../../features/player/presentation/cubit/player_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. Data Sources
  sl.registerLazySingleton<CoursesAssetDataSource>(
    () => const CoursesAssetDataSourceImpl(),
  );
  sl.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // 3. Repositories
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(assetDataSource: sl()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(localDataSource: sl()),
  );

  // 4. Domain Services
  sl.registerLazySingleton<ProgressService>(
    () => const ProgressService(),
  );

  // 5. Cubits
  sl.registerFactory<CoursesCubit>(
    () => CoursesCubit(
      coursesRepository: sl(),
      progressRepository: sl(),
      progressService: sl(),
    ),
  );

  sl.registerFactory<PlayerCubit>(
    () => PlayerCubit(
      progressRepository: sl(),
      progressService: sl(),
    ),
  );
}
