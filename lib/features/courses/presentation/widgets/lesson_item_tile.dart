import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';
import '../../../progress/domain/entities/lesson_progress.dart';
import '../../../progress/presentation/widgets/progress_badge.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/duration_formatter.dart';

class LessonItemTile extends StatelessWidget {
  final int index;
  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;

  const LessonItemTile({
    super.key,
    required this.index,
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  void _showLockedDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.lock_rounded,
              color: AppTheme.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.locked,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          l10n.lockedMessage,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.understood,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? () => _showLockedDialog(context) : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Index / Leading icon
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFFE2E8F0)
                        : (status == LessonStatus.completed
                            ? AppTheme.success.withValues(alpha: 0.12)
                            : AppTheme.primary.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLocked
                        ? const Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            color: AppTheme.locked,
                          )
                        : (status == LessonStatus.completed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppTheme.success,
                              )
                            : Text(
                                '$index',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                ),
                              )),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? AppTheme.locked
                              : AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: isLocked
                                ? AppTheme.locked
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DurationFormatter.formatSeconds(
                              lesson.durationSec,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: isLocked
                                  ? AppTheme.locked
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                ProgressBadge(status: status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
