import '../../domain/entities/lesson_progress.dart';

class LessonProgressModel {
  final String lessonId;
  final String courseId;
  final int lastPositionSeconds;
  final int totalDurationSeconds;
  final bool isCompleted;
  final int updatedAtMillis;

  const LessonProgressModel({
    required this.lessonId,
    required this.courseId,
    required this.lastPositionSeconds,
    required this.totalDurationSeconds,
    required this.isCompleted,
    required this.updatedAtMillis,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      lastPositionSeconds: (json['lastPositionSeconds'] as num?)?.toInt() ?? 0,
      totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      updatedAtMillis: (json['updatedAtMillis'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'lastPositionSeconds': lastPositionSeconds,
      'totalDurationSeconds': totalDurationSeconds,
      'isCompleted': isCompleted,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  LessonProgress toEntity() {
    return LessonProgress(
      lessonId: lessonId,
      courseId: courseId,
      lastPositionSeconds: lastPositionSeconds,
      totalDurationSeconds: totalDurationSeconds,
      isCompleted: isCompleted,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
    );
  }

  factory LessonProgressModel.fromEntity(LessonProgress entity) {
    return LessonProgressModel(
      lessonId: entity.lessonId,
      courseId: entity.courseId,
      lastPositionSeconds: entity.lastPositionSeconds,
      totalDurationSeconds: entity.totalDurationSeconds,
      isCompleted: entity.isCompleted,
      updatedAtMillis: entity.updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}
