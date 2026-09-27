import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/lesson_progress_model.dart';

abstract class ProgressLocalDataSource {
  Future<Map<String, LessonProgressModel>> getAllProgress();
  Future<LessonProgressModel?> getLessonProgress(String lessonId);
  Future<void> saveProgress(LessonProgressModel progress);
  Future<Set<String>> getCompletedLessonIds();
  Future<void> markLessonCompleted(String lessonId);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _progressKeyPrefix = 'thaheen_progress_';
  static const String _completedLessonsKey = 'thaheen_completed_lessons';

  const ProgressLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Map<String, LessonProgressModel>> getAllProgress() async {
    try {
      final keys = sharedPreferences.getKeys();
      final Map<String, LessonProgressModel> result = {};

      for (final key in keys) {
        if (key.startsWith(_progressKeyPrefix)) {
          final jsonStr = sharedPreferences.getString(key);
          if (jsonStr != null) {
            final Map<String, dynamic> decoded = json.decode(jsonStr);
            final model = LessonProgressModel.fromJson(decoded);
            result[model.lessonId] = model;
          }
        }
      }
      return result;
    } catch (e) {
      throw StorageException('تعذر قراءة بيانات تقدم الدروس: $e');
    }
  }

  @override
  Future<LessonProgressModel?> getLessonProgress(String lessonId) async {
    try {
      final jsonStr =
          sharedPreferences.getString('$_progressKeyPrefix$lessonId');
      if (jsonStr == null) return null;
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      return LessonProgressModel.fromJson(decoded);
    } catch (e) {
      throw StorageException('تعذر قراءة تقدم الدرس $lessonId: $e');
    }
  }

  @override
  Future<void> saveProgress(LessonProgressModel progress) async {
    try {
      final jsonStr = json.encode(progress.toJson());
      await sharedPreferences.setString(
        '$_progressKeyPrefix${progress.lessonId}',
        jsonStr,
      );
    } catch (e) {
      throw StorageException('تعذر حفظ تقدم الدرس: $e');
    }
  }

  @override
  Future<Set<String>> getCompletedLessonIds() async {
    try {
      final list =
          sharedPreferences.getStringList(_completedLessonsKey) ?? [];
      return list.toSet();
    } catch (e) {
      throw StorageException('تعذر قراءة قائمة الدروس المكتملة: $e');
    }
  }

  @override
  Future<void> markLessonCompleted(String lessonId) async {
    try {
      final list =
          sharedPreferences.getStringList(_completedLessonsKey) ?? [];
      final set = list.toSet()..add(lessonId);
      await sharedPreferences.setStringList(
        _completedLessonsKey,
        set.toList(),
      );
    } catch (e) {
      throw StorageException('تعذر حفظ اكتمال الدرس: $e');
    }
  }
}
