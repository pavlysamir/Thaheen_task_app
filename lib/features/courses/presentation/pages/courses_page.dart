import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatefulWidget {
  final VoidCallback onToggleLanguage;

  const CoursesPage({super.key, required this.onToggleLanguage});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.appTitle,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language_rounded, size: 18),
            label: Text(
              l10n.isArabic ? 'English' : 'العربية',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (state is CoursesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoading,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<CoursesCubit>().loadCourses(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CoursesLoaded) {
            if (state.courses.isEmpty) {
              return Center(
                child: Text(
                  l10n.noCourses,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => context.read<CoursesCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                  // Continue Watching card (if available)
                  if (state.continueWatching != null)
                    ContinueWatchingCard(
                      item: state.continueWatching!,
                      onTap: () async {
                        final item = state.continueWatching!;
                        await context.pushNamed(
                          'player',
                          pathParameters: {
                            'courseId': item.course.id,
                            'lessonId': item.lesson.id,
                          },
                          extra: {'course': item.course, 'lesson': item.lesson},
                        );
                        if (context.mounted) {
                          context.read<CoursesCubit>().refresh();
                        }
                      },
                    ),

                  // Courses Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14, top: 4),
                    child: Text(
                      l10n.allCourses,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  // Courses List
                  ...state.courses.map((course) {
                    final progress = state.getCourseProgress(course.id);
                    return CourseCard(
                      course: course,
                      progress: progress,
                      onTap: () async {
                        await context.pushNamed(
                          'course-detail',
                          pathParameters: {'courseId': course.id},
                          extra: course,
                        );
                        if (context.mounted) {
                          context.read<CoursesCubit>().refresh();
                        }
                      },
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
