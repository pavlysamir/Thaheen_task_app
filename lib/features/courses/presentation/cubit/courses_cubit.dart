import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/courses_repository.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesRepository coursesRepository;

  CoursesCubit({
    required this.coursesRepository,
  }) : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    await _fetchData();
  }

  Future<void> refresh() async {
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final courses = await coursesRepository.getCourses();
      emit(CoursesLoaded(courses: courses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
