import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/lesson.dart';
import '../../../progress/domain/entities/lesson_progress.dart';
import '../../../progress/presentation/widgets/progress_badge.dart';

class LessonItemTile extends StatelessWidget {
  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;

  const LessonItemTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLocked ? Colors.grey.shade200 : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? AppTheme.locked.withValues(alpha: 0.1)
              : AppTheme.primary.withValues(alpha: 0.1),
          child: Icon(
            isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
            color: isLocked ? AppTheme.locked : AppTheme.primary,
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isLocked ? AppTheme.textMuted : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          DurationFormatter.formatSeconds(lesson.durationSec),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        trailing: ProgressBadge(status: status),
        onTap: onTap,
      ),
    );
  }
}
