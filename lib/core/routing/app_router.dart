import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/courses/domain/entities/course.dart';
import '../../features/courses/domain/entities/lesson.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/player/presentation/pages/lesson_player_page.dart';
import '../di/injection_container.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';

GoRouter createRouter({VoidCallback? onToggleLanguage}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'courses',
        builder: (context, state) => CoursesPage(
          onToggleLanguage: onToggleLanguage,
        ),
      ),
      GoRoute(
        path: '/course/:courseId',
        name: 'course-detail',
        builder: (context, state) {
          final course = state.extra as Course?;
          if (course != null) {
            return CourseDetailPage(course: course);
          }
          final courseId = state.pathParameters['courseId'] ?? '';
          return FutureBuilder<Course>(
            future: sl<CoursesRepository>().getCourseById(courseId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CourseDetailPage(course: snapshot.data!);
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/course/:courseId/lesson/:lessonId',
        name: 'player',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final course = extra?['course'] as Course?;
          final lesson = extra?['lesson'] as Lesson?;

          if (course != null && lesson != null) {
            return LessonPlayerPage(
              course: course,
              lesson: lesson,
            );
          }

          final courseId = state.pathParameters['courseId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';

          return FutureBuilder<Course>(
            future: sl<CoursesRepository>().getCourseById(courseId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final foundCourse = snapshot.data!;
                final foundLesson = foundCourse.findLesson(lessonId);
                if (foundLesson != null) {
                  return LessonPlayerPage(
                    course: foundCourse,
                    lesson: foundLesson,
                  );
                }
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
    ],
  );
}
