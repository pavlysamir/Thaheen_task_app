import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/courses/domain/entities/course.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
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
    ],
  );
}
