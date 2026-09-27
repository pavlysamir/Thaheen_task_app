import '../../../../core/error/exceptions.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/courses_repository.dart';
import '../datasources/courses_asset_datasource.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesAssetDataSource assetDataSource;
  List<Course>? _cachedCourses;

  CoursesRepositoryImpl({required this.assetDataSource});

  @override
  Future<List<Course>> getCourses() async {
    if (_cachedCourses != null && _cachedCourses!.isNotEmpty) {
      return _cachedCourses!;
    }

    final models = await assetDataSource.getCourses();
    _cachedCourses = models.map((m) => m.toEntity()).toList();
    return _cachedCourses!;
  }

  @override
  Future<Course> getCourseById(String courseId) async {
    final courses = await getCourses();
    final course = courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw AssetException('المقرر المطلوب غير موجود: $courseId'),
    );
    return course;
  }
}
