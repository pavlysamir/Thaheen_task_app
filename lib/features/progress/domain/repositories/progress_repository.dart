import '../entities/lesson_progress.dart';

abstract class ProgressRepository {
  Future<Map<String, LessonProgress>> getAllProgress();
  Future<LessonProgress?> getLessonProgress(String lessonId);
  Future<Set<String>> getCompletedLessonIds();
  Future<void> saveLessonPosition({
    required String courseId,
    required String lessonId,
    required int positionSeconds,
    required int totalDurationSeconds,
  });
  Future<void> markLessonCompleted({
    required String courseId,
    required String lessonId,
    required int totalDurationSeconds,
  });
}
