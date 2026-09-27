import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/data/datasources/courses_asset_datasource.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/presentation/cubit/courses_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. Data Sources
  sl.registerLazySingleton<CoursesAssetDataSource>(
    () => const CoursesAssetDataSourceImpl(),
  );

  // 3. Repositories
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(assetDataSource: sl()),
  );

  // 4. Cubits
  sl.registerFactory<CoursesCubit>(
    () => CoursesCubit(
      coursesRepository: sl(),
    ),
  );
}
