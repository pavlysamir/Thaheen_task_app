import 'package:equatable/equatable.dart';
import '../../domain/entities/course.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<Course> courses;

  const CoursesLoaded({
    required this.courses,
  });

  Course? getCourse(String courseId) {
    try {
      return courses.firstWhere((c) => c.id == courseId);
    } catch (_) {
      return null;
    }
  }

  double getCourseProgress(String courseId) {
    return 0.0;
  }

  @override
  List<Object?> get props => [courses];
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
