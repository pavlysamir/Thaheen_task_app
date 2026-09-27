import '../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/lesson_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource localDataSource;

  ProgressRepositoryImpl({required this.localDataSource});

  @override
  Future<Map<String, LessonProgress>> getAllProgress() async {
    final models = await localDataSource.getAllProgress();
    return models.map((key, value) => MapEntry(key, value.toEntity()));
  }

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async {
    final model = await localDataSource.getLessonProgress(lessonId);
    return model?.toEntity();
  }

  @override
  Future<Set<String>> getCompletedLessonIds() async {
    return await localDataSource.getCompletedLessonIds();
  }

  @override
  Future<void> saveLessonPosition({
    required String courseId,
    required String lessonId,
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    final existing = await localDataSource.getLessonProgress(lessonId);
    final isCompleted = existing?.isCompleted ?? false;

    final updatedModel = LessonProgressModel(
      lessonId: lessonId,
      courseId: courseId,
      lastPositionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
      isCompleted: isCompleted,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );

    await localDataSource.saveProgress(updatedModel);
  }

  @override
  Future<void> markLessonCompleted({
    required String courseId,
    required String lessonId,
    required int totalDurationSeconds,
  }) async {
    final existing = await localDataSource.getLessonProgress(lessonId);
    final updatedModel = LessonProgressModel(
      lessonId: lessonId,
      courseId: courseId,
      lastPositionSeconds: existing?.lastPositionSeconds ?? totalDurationSeconds,
      totalDurationSeconds: totalDurationSeconds,
      isCompleted: true,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );

    await localDataSource.saveProgress(updatedModel);
    await localDataSource.markLessonCompleted(lessonId);
  }
}
