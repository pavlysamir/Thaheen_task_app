import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:thaheen_lms/features/courses/domain/entities/course.dart';
import 'package:thaheen_lms/features/courses/domain/entities/lesson.dart';
import 'package:thaheen_lms/features/progress/domain/repositories/progress_repository.dart';
import 'package:thaheen_lms/features/progress/domain/services/progress_service.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final ProgressRepository progressRepository;
  final ProgressService progressService;

  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;

  Course? _currentCourse;
  Lesson? _currentLesson;
  int _lastSavedSecond = -1;
  bool _hasCompletedSession = false;

  PlayerCubit({
    required this.progressRepository,
    required this.progressService,
  }) : super(const PlayerState());

  Future<void> initializeLesson({
    required Course course,
    required Lesson lesson,
  }) async {
    _currentCourse = course;
    _currentLesson = lesson;
    _lastSavedSecond = -1;
    _hasCompletedSession = false;

    emit(state.copyWith(
      status: PlayerStatus.loading,
      errorMessage: null,
      justCompletedNow: false,
    ));

    // Dispose any previous controller
    await _disposeController();

    try {
      // 1. Check existing progress in storage
      final savedProgress =
          await progressRepository.getLessonProgress(lesson.id);
      final isAlreadyCompleted = savedProgress?.isCompleted ?? false;
      final resumePositionSec = savedProgress?.lastPositionSeconds ?? 0;

      // 2. Check next lesson unlock state
      final next = course.getNextLesson(lesson.id);
      final completedIds = await progressRepository.getCompletedLessonIds();
      final isNextUnlocked = next != null &&
          progressService.isLessonUnlocked(
            lessonId: next.id,
            course: course,
            completedLessonIds: completedIds,
          );

      // 3. Initialize video player controller
      final controller = VideoPlayerController.asset(lesson.video);
      _controller = controller;

      await controller.initialize();

      // 4. Resume from last saved position if not completed
      if (resumePositionSec > 0 &&
          resumePositionSec < controller.value.duration.inSeconds) {
        await controller.seekTo(Duration(seconds: resumePositionSec));
      }

      // Set playback speed
      await controller.setPlaybackSpeed(state.playbackSpeed);

      // Listen to position changes
      controller.addListener(_onControllerUpdate);

      emit(state.copyWith(
        status: PlayerStatus.ready,
        duration: controller.value.duration,
        position: controller.value.position,
        isPlaying: controller.value.isPlaying,
        isCompleted: isAlreadyCompleted,
        nextLesson: next,
        isNextLessonUnlocked: isNextUnlocked,
      ));

      // Auto start playback
      await controller.play();
    } catch (e) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'تعذر تشغيل الفيديو: ${lesson.video}\nتأكد من وجود الملف.',
      ));
    }
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final currentPosition = controller.value.position;
    final totalDuration = controller.value.duration;
    final isPlaying = controller.value.isPlaying;

    final currentSec = currentPosition.inSeconds;
    final totalSec = totalDuration.inSeconds;

    // Check 90% completion rule
    if (!_hasCompletedSession &&
        !state.isCompleted &&
        progressService.shouldComplete(
          currentPositionSec: currentSec,
          totalDurationSec: totalSec,
        )) {
      _hasCompletedSession = true;
      _triggerCompletion(totalSec);
    }

    // Periodic position persistence (every 3 seconds)
    if (currentSec != _lastSavedSecond && currentSec % 3 == 0) {
      _lastSavedSecond = currentSec;
      _persistCurrentPosition(currentSec, totalSec);
    }

    emit(state.copyWith(
      position: currentPosition,
      duration: totalDuration,
      isPlaying: isPlaying,
    ));
  }

  Future<void> _triggerCompletion(int totalSec) async {
    final course = _currentCourse;
    final lesson = _currentLesson;
    if (course == null || lesson == null) return;

    await progressRepository.markLessonCompleted(
      courseId: course.id,
      lessonId: lesson.id,
      totalDurationSeconds: totalSec,
    );

    // Refresh completed IDs to recheck if next lesson is unlocked now
    final completedIds = await progressRepository.getCompletedLessonIds();
    final next = course.getNextLesson(lesson.id);
    final isNextUnlocked = next != null &&
        progressService.isLessonUnlocked(
          lessonId: next.id,
          course: course,
          completedLessonIds: completedIds,
        );

    emit(state.copyWith(
      isCompleted: true,
      justCompletedNow: true,
      nextLesson: next,
      isNextLessonUnlocked: isNextUnlocked,
    ));
  }

  void resetCompletionToastFlag() {
    emit(state.copyWith(justCompletedNow: false));
  }

  Future<void> _persistCurrentPosition(int currentSec, int totalSec) async {
    final course = _currentCourse;
    final lesson = _currentLesson;
    if (course == null || lesson == null) return;

    await progressRepository.saveLessonPosition(
      courseId: course.id,
      lessonId: lesson.id,
      positionSeconds: currentSec,
      totalDurationSeconds: totalSec,
    );
  }

  void togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void seekTo(Duration position) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.seekTo(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(speed);
    }
    emit(state.copyWith(playbackSpeed: speed));
  }

  Future<void> toggleFullscreen() async {
    final willBeFullscreen = !state.isFullscreen;
    emit(state.copyWith(isFullscreen: willBeFullscreen));

    if (willBeFullscreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onControllerUpdate);
      // Save current position one last time before destroying
      if (controller.value.isInitialized) {
        await _persistCurrentPosition(
          controller.value.position.inSeconds,
          controller.value.duration.inSeconds,
        );
      }
      await controller.dispose();
      _controller = null;
    }
  }

  @override
  Future<void> close() async {
    // Reset orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _disposeController();
    return super.close();
  }
}
