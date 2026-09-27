import 'package:equatable/equatable.dart';
import 'package:thaheen_lms/features/courses/domain/entities/lesson.dart';

enum PlayerStatus { initial, loading, ready, error }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final String? errorMessage;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double playbackSpeed;
  final bool isFullscreen;
  final bool isCompleted;
  final bool justCompletedNow; // Used to trigger celebration toast once
  final bool isNextLessonUnlocked;
  final Lesson? nextLesson;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
    this.isFullscreen = false,
    this.isCompleted = false,
    this.justCompletedNow = false,
    this.isNextLessonUnlocked = false,
    this.nextLesson,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    String? errorMessage,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    double? playbackSpeed,
    bool? isFullscreen,
    bool? isCompleted,
    bool? justCompletedNow,
    bool? isNextLessonUnlocked,
    Lesson? nextLesson,
  }) {
    return PlayerState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isCompleted: isCompleted ?? this.isCompleted,
      justCompletedNow: justCompletedNow ?? this.justCompletedNow,
      isNextLessonUnlocked: isNextLessonUnlocked ?? this.isNextLessonUnlocked,
      nextLesson: nextLesson ?? this.nextLesson,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        position,
        duration,
        isPlaying,
        playbackSpeed,
        isFullscreen,
        isCompleted,
        justCompletedNow,
        isNextLessonUnlocked,
        nextLesson,
      ];
}
