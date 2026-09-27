import 'package:thaheen_lms/features/courses/domain/entities/course.dart';
import 'package:thaheen_lms/features/courses/domain/entities/lesson.dart';
import '../entities/lesson_progress.dart';

class ContinueWatchingItem {
  final Course course;
  final Lesson lesson;
  final LessonProgress progress;

  const ContinueWatchingItem({
    required this.course,
    required this.lesson,
    required this.progress,
  });
}

class ProgressService {
  const ProgressService();

  /// Rule 1: A lesson is completed automatically when watched >= 90%
  bool shouldComplete({
    required int currentPositionSec,
    required int totalDurationSec,
  }) {
    if (totalDurationSec <= 0 || currentPositionSec < 0) {
      return false;
    }
    return (currentPositionSec / totalDurationSec) >= 0.90;
  }

  /// Rule 2: Sequential unlock - a lesson is unlocked if it is the first lesson,
  /// or if the immediately preceding lesson is completed.
  bool isLessonUnlocked({
    required String lessonId,
    required Course course,
    required Set<String> completedLessonIds,
  }) {
    final allLessons = course.allLessons;
    final index = allLessons.indexWhere((l) => l.id == lessonId);

    // If lesson not found in course, treat as locked for safety
    if (index == -1) return false;

    // First lesson of the course is always unlocked
    if (index == 0) return true;

    // Any subsequent lesson is unlocked only if previous lesson is completed
    final previousLesson = allLessons[index - 1];
    return completedLessonIds.contains(previousLesson.id);
  }

  /// Rule 3: Progress % calculation for a course (0.0 to 1.0)
  double calculateCourseProgress({
    required Course course,
    required Set<String> completedLessonIds,
  }) {
    final allLessons = course.allLessons;
    if (allLessons.isEmpty) return 0.0;

    int completedCount = 0;
    for (final lesson in allLessons) {
      if (completedLessonIds.contains(lesson.id)) {
        completedCount++;
      }
    }

    final ratio = completedCount / allLessons.length;
    return ratio.clamp(0.0, 1.0);
  }

  /// Rule 4: "Continue watching" card if the student has an unfinished lesson
  ContinueWatchingItem? getContinueWatching({
    required List<Course> courses,
    required Map<String, LessonProgress> progressMap,
  }) {
    final inProgressItems = <ContinueWatchingItem>[];

    for (final course in courses) {
      for (final lesson in course.allLessons) {
        final progress = progressMap[lesson.id];
        if (progress != null &&
            !progress.isCompleted &&
            progress.lastPositionSeconds > 0) {
          inProgressItems.add(
            ContinueWatchingItem(
              course: course,
              lesson: lesson,
              progress: progress,
            ),
          );
        }
      }
    }

    if (inProgressItems.isEmpty) return null;

    // Sort by latest update timestamp descending
    inProgressItems.sort((a, b) {
      final aTime = a.progress.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.progress.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return inProgressItems.first;
  }

  /// Helper to determine the status of a specific lesson in a course
  LessonStatus getLessonStatus({
    required String lessonId,
    required Course course,
    required Map<String, LessonProgress> progressMap,
    required Set<String> completedLessonIds,
  }) {
    if (!isLessonUnlocked(
      lessonId: lessonId,
      course: course,
      completedLessonIds: completedLessonIds,
    )) {
      return LessonStatus.locked;
    }

    if (completedLessonIds.contains(lessonId)) {
      return LessonStatus.completed;
    }

    final progress = progressMap[lessonId];
    if (progress != null && progress.lastPositionSeconds > 0) {
      return LessonStatus.inProgress;
    }

    return LessonStatus.notStarted;
  }
}
