import 'package:equatable/equatable.dart';
import 'section.dart';
import 'lesson.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<Section> sections;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  /// Flat list of all lessons across all sections in order
  List<Lesson> get allLessons {
    return sections.expand((section) => section.lessons).toList();
  }

  /// Total count of lessons
  int get totalLessonsCount => allLessons.length;

  /// Find lesson by id
  Lesson? findLesson(String lessonId) {
    for (final section in sections) {
      for (final lesson in section.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  /// Find next lesson in order
  Lesson? getNextLesson(String currentLessonId) {
    final flat = allLessons;
    final index = flat.indexWhere((l) => l.id == currentLessonId);
    if (index != -1 && index + 1 < flat.length) {
      return flat[index + 1];
    }
    return null;
  }

  @override
  List<Object?> get props => [id, title, instructor, thumbnail, sections];
}
