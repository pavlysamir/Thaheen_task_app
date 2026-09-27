import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/courses_repository.dart';
import '../../../progress/domain/repositories/progress_repository.dart';
import '../../../progress/domain/services/progress_service.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesRepository coursesRepository;
  final ProgressRepository progressRepository;
  final ProgressService progressService;

  CoursesCubit({
    required this.coursesRepository,
    required this.progressRepository,
    required this.progressService,
  }) : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    await _fetchData();
  }

  Future<void> refresh() async {
    // Silent refresh to update progress without showing a blocking spinner
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final courses = await coursesRepository.getCourses();
      final progressMap = await progressRepository.getAllProgress();
      final completedLessonIds = await progressRepository.getCompletedLessonIds();

      final courseProgressMap = <String, double>{};
      for (final course in courses) {
        courseProgressMap[course.id] = progressService.calculateCourseProgress(
          course: course,
          completedLessonIds: completedLessonIds,
        );
      }

      final continueWatching = progressService.getContinueWatching(
        courses: courses,
        progressMap: progressMap,
      );

      emit(
        CoursesLoaded(
          courses: courses,
          progressMap: progressMap,
          completedLessonIds: completedLessonIds,
          courseProgressMap: courseProgressMap,
          continueWatching: continueWatching,
        ),
      );
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
