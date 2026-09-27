import 'package:equatable/equatable.dart';

enum LessonStatus {
  notStarted,
  inProgress,
  completed,
  locked,
}

class LessonProgress extends Equatable {
  final String lessonId;
  final String courseId;
  final int lastPositionSeconds;
  final int totalDurationSeconds;
  final bool isCompleted;
  final DateTime? updatedAt;

  const LessonProgress({
    required this.lessonId,
    required this.courseId,
    this.lastPositionSeconds = 0,
    this.totalDurationSeconds = 0,
    this.isCompleted = false,
    this.updatedAt,
  });

  LessonProgress copyWith({
    String? lessonId,
    String? courseId,
    int? lastPositionSeconds,
    int? totalDurationSeconds,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      courseId: courseId ?? this.courseId,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        lessonId,
        courseId,
        lastPositionSeconds,
        totalDurationSeconds,
        isCompleted,
        updatedAt,
      ];
}
