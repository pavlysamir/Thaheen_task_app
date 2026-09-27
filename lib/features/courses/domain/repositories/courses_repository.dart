import '../entities/course.dart';

abstract class CoursesRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(String courseId);
}
