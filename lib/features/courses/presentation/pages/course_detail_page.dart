import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/course.dart';
import '../../../progress/domain/entities/lesson_progress.dart';
import '../../../progress/domain/services/progress_service.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/lesson_item_tile.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الدرس مُقفل 🔒'),
        content: const Text(
          'يرجى إكمال الدرس السابق أولاً لتتمكن من فتح هذا الدرس.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          final completedIds = state is CoursesLoaded
              ? state.completedLessonIds
              : <String>{};
          final progressMap = state is CoursesLoaded
              ? state.progressMap
              : <String, LessonProgress>{};

          const progressService = ProgressService();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  course.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppTheme.surfaceVariant,
                    child: const Icon(Icons.school, size: 48, color: AppTheme.primary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.instructor,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...course.sections.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                    ...section.lessons.map((lesson) {
                      final isUnlocked = progressService.isLessonUnlocked(
                        lessonId: lesson.id,
                        course: course,
                        completedLessonIds: completedIds,
                      );
                      final progress = progressMap[lesson.id];
                      final isCompleted = completedIds.contains(lesson.id);

                      LessonStatus status;
                      if (!isUnlocked) {
                        status = LessonStatus.locked;
                      } else if (isCompleted) {
                        status = LessonStatus.completed;
                      } else if (progress != null && progress.lastPositionSeconds > 0) {
                        status = LessonStatus.inProgress;
                      } else {
                        status = LessonStatus.notStarted;
                      }

                      return LessonItemTile(
                        lesson: lesson,
                        status: status,
                        onTap: () {
                          if (!isUnlocked) {
                            _showLockedDialog(context);
                          } else {
                            context.push(
                              '/course/${course.id}/lesson/${lesson.id}',
                              extra: {
                                'course': course,
                                'lesson': lesson,
                              },
                            );
                          }
                        },
                      );
                    }),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
