import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/exceptions.dart';
import '../models/course_model.dart';

abstract class CoursesAssetDataSource {
  Future<List<CourseModel>> getCourses();
}

class CoursesAssetDataSourceImpl implements CoursesAssetDataSource {
  final String assetPath;

  const CoursesAssetDataSourceImpl({
    this.assetPath = 'assets/data/courses.json',
  });

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic> || !decoded.containsKey('courses')) {
        throw const AssetException('تنسيق ملف المقررات غير صالح');
      }

      final coursesList = decoded['courses'] as List<dynamic>;
      return coursesList
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AssetException {
      rethrow;
    } catch (e) {
      throw AssetException('تعذر قراءة ملف المقررات من الأصول: $e');
    }
  }
}
