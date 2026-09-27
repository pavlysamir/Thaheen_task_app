import 'package:equatable/equatable.dart';
import '../../domain/entities/course.dart';
import '../../../progress/domain/entities/lesson_progress.dart';
import '../../../progress/domain/services/progress_service.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<Course> courses;
  final Map<String, LessonProgress> progressMap;
  final Set<String> completedLessonIds;
  final Map<String, double> courseProgressMap;
  final ContinueWatchingItem? continueWatching;

  const CoursesLoaded({
    required this.courses,
    required this.progressMap,
    required this.completedLessonIds,
    required this.courseProgressMap,
    this.continueWatching,
  });

  Course? getCourse(String courseId) {
    try {
      return courses.firstWhere((c) => c.id == courseId);
    } catch (_) {
      return null;
    }
  }

  double getCourseProgress(String courseId) {
    return courseProgressMap[courseId] ?? 0.0;
  }

  @override
  List<Object?> get props => [
        courses,
        progressMap,
        completedLessonIds,
        courseProgressMap,
        continueWatching,
      ];
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
