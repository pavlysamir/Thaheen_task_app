import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatefulWidget {
  final VoidCallback? onToggleLanguage;

  const CoursesPage({super.key, this.onToggleLanguage});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thaheen LMS'),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CoursesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CoursesCubit>().loadCourses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CoursesLoaded) {
            final continueItem = state.continueWatching;

            return RefreshIndicator(
              onRefresh: () => context.read<CoursesCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  if (continueItem != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ContinueWatchingCard(
                        item: continueItem,
                        onTap: () {
                          context.push(
                            '/course/${continueItem.course.id}/lesson/${continueItem.lesson.id}',
                            extra: {
                              'course': continueItem.course,
                              'lesson': continueItem.lesson,
                            },
                          );
                        },
                      ),
                    ),
                  ...state.courses.map(
                    (course) => CourseCard(
                      course: course,
                      progress: state.getCourseProgress(course.id),
                      onTap: () {
                        context.push(
                          '/course/${course.id}',
                          extra: course,
                        );
                      },
                    ),
                  ),
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
