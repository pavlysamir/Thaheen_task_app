import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final int durationSec;
  final String video;

  const Lesson({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });

  @override
  List<Object?> get props => [id, title, durationSec, video];
}
