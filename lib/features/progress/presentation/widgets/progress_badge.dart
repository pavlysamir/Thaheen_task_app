import 'package:flutter/material.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../../../core/theme/app_theme.dart';

class ProgressBadge extends StatelessWidget {
  final LessonStatus status;

  const ProgressBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case LessonStatus.completed:
        bg = AppTheme.success.withValues(alpha: 0.12);
        fg = AppTheme.success;
        icon = Icons.check_circle_rounded;
        label = 'مكتمل';
        break;
      case LessonStatus.inProgress:
        bg = AppTheme.warning.withValues(alpha: 0.15);
        fg = AppTheme.warning;
        icon = Icons.play_circle_fill_rounded;
        label = 'قيد المشاهدة';
        break;
      case LessonStatus.locked:
        bg = AppTheme.locked.withValues(alpha: 0.12);
        fg = AppTheme.locked;
        icon = Icons.lock_outline_rounded;
        label = 'مُقفل';
        break;
      case LessonStatus.notStarted:
        bg = const Color(0xFFE2E8F0);
        fg = AppTheme.textSecondary;
        icon = Icons.radio_button_unchecked_rounded;
        label = 'لم يبدأ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
