import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:thaheen_lms/core/di/injection_container.dart';
import 'package:thaheen_lms/core/theme/app_theme.dart';
import 'package:thaheen_lms/core/localization/app_localizations.dart';
import 'package:thaheen_lms/features/courses/domain/entities/course.dart';
import 'package:thaheen_lms/features/courses/domain/entities/lesson.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import '../widgets/player_controls_overlay.dart';

class LessonPlayerPage extends StatelessWidget {
  final Course course;
  final Lesson lesson;

  const LessonPlayerPage({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlayerCubit>()
        ..initializeLesson(
          course: course,
          lesson: lesson,
        ),
      child: _LessonPlayerView(course: course, lesson: lesson),
    );
  }
}

class _LessonPlayerView extends StatelessWidget {
  final Course course;
  final Lesson lesson;

  const _LessonPlayerView({
    required this.course,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (previous, current) => current.justCompletedNow,
      listener: (context, state) {
        if (state.justCompletedNow) {
          context.read<PlayerCubit>().resetCompletionToastFlag();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.success,
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.lessonCompletedToast,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        final controller = cubit.controller;

        if (state.isFullscreen) {
          // Fullscreen Mode
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (controller != null && controller.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                PlayerControlsOverlay(
                  state: state,
                  courseTitle: course.title,
                  lessonTitle: lesson.title,
                  onTogglePlay: cubit.togglePlay,
                  onSeek: cubit.seekTo,
                  onSpeedChanged: cubit.setPlaybackSpeed,
                  onToggleFullscreen: cubit.toggleFullscreen,
                  onNextLesson: state.nextLesson != null
                      ? () => _navigateToNext(context, state.nextLesson!)
                      : null,
                  onBack: () async {
                    await cubit.toggleFullscreen();
                  },
                ),
              ],
            ),
          );
        }

        // Normal Portrait Mode
        return Scaffold(
          appBar: AppBar(
            title: Text(
              lesson.title,
              style: const TextStyle(fontSize: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player Container
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: _buildVideoContent(context, state, cubit, controller),
                ),
              ),

              // Lesson Details & Actions below player
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status Badge & Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: state.isCompleted
                                ? AppTheme.success.withValues(alpha: 0.12)
                                : AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 14,
                                color: state.isCompleted
                                    ? AppTheme.success
                                    : AppTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.isCompleted
                                    ? l10n.completed
                                    : l10n.inProgress,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: state.isCompleted
                                      ? AppTheme.success
                                      : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.playbackSpeed}x',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const Divider(height: 32),

                    // Next Lesson Action Card
                    if (state.nextLesson != null) ...[
                      Text(
                        l10n.nextLesson,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: state.isNextLessonUnlocked
                              ? AppTheme.primary.withValues(alpha: 0.06)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: state.isNextLessonUnlocked
                                ? AppTheme.primary.withValues(alpha: 0.3)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: state.isNextLessonUnlocked
                                    ? AppTheme.primary
                                    : AppTheme.locked,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isNextLessonUnlocked
                                    ? Icons.skip_next_rounded
                                    : Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.nextLesson!.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: state.isNextLessonUnlocked
                                          ? AppTheme.textPrimary
                                          : AppTheme.locked,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.isNextLessonUnlocked
                                        ? l10n.nextLesson
                                        : l10n.lockedMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: state.isNextLessonUnlocked
                                          ? AppTheme.primary
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (state.isNextLessonUnlocked)
                              ElevatedButton(
                                onPressed: () => _navigateToNext(
                                  context,
                                  state.nextLesson!,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(l10n.nextLesson),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    PlayerState state,
    PlayerCubit cubit,
    VideoPlayerController? controller,
  ) {
    final l10n = AppLocalizations.of(context);

    if (state.status == PlayerStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryLight),
      );
    }

    if (state.status == PlayerStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? l10n.errorLoading,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => cubit.initializeLesson(
                  course: course,
                  lesson: lesson,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(l10n.retry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controller != null && controller.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          PlayerControlsOverlay(
            state: state,
            courseTitle: course.title,
            lessonTitle: lesson.title,
            onTogglePlay: cubit.togglePlay,
            onSeek: cubit.seekTo,
            onSpeedChanged: cubit.setPlaybackSpeed,
            onToggleFullscreen: cubit.toggleFullscreen,
            onNextLesson: state.nextLesson != null
                ? () => _navigateToNext(context, state.nextLesson!)
                : null,
            onBack: () => context.pop(),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _navigateToNext(BuildContext context, Lesson nextLesson) {
    // Navigate with replacement to seamlessly switch to next lesson
    context.pushReplacementNamed(
      'player',
      pathParameters: {
        'courseId': course.id,
        'lessonId': nextLesson.id,
      },
      extra: {
        'course': course,
        'lesson': nextLesson,
      },
    );
  }
}
