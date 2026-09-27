import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/lesson.dart';

class LessonItemTile extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonItemTile({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.play_arrow, color: AppTheme.primary),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          DurationFormatter.formatSeconds(lesson.durationSec),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        onTap: onTap,
      ),
    );
  }
}
