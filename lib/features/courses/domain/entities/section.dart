import 'package:equatable/equatable.dart';
import 'lesson.dart';

class Section extends Equatable {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const Section({
    required this.id,
    required this.title,
    required this.lessons,
  });

  @override
  List<Object?> get props => [id, title, lessons];
}
