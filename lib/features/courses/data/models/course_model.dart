import '../../domain/entities/course.dart';
import 'section_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<SectionModel> sections;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      thumbnail: json['thumbnail'] as String,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => SectionModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'thumbnail': thumbnail,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  Course toEntity() {
    return Course(
      id: id,
      title: title,
      instructor: instructor,
      thumbnail: thumbnail,
      sections: sections.map((s) => s.toEntity()).toList(),
    );
  }
}
