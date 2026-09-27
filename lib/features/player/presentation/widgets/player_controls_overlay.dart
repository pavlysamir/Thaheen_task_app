import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../cubit/player_state.dart';
import 'playback_speed_dialog.dart';
import 'rtl_seek_bar.dart';

class PlayerControlsOverlay extends StatefulWidget {
  final PlayerState state;
  final String lessonTitle;
  final String courseTitle;
  final VoidCallback onTogglePlay;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleFullscreen;
  final VoidCallback? onNextLesson;
  final VoidCallback onBack;

  const PlayerControlsOverlay({
    super.key,
    required this.state,
    required this.lessonTitle,
    required this.courseTitle,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onSpeedChanged,
    required this.onToggleFullscreen,
    required this.onNextLesson,
    required this.onBack,
  });

  @override
  State<PlayerControlsOverlay> createState() => _PlayerControlsOverlayState();
}

class _PlayerControlsOverlayState extends State<PlayerControlsOverlay> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (widget.state.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startHideTimer();
    }
  }

  void _resetTimer() {
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_controlsVisible,
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 280;

                Widget content = Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 8 : 16,
                        vertical: isCompact ? 4 : 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: widget.onBack,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            tooltip: l10n.close,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCompact)
                                  Text(
                                    widget.courseTitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Text(
                                  widget.lessonTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompact ? 13 : 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Speed Button
                          InkWell(
                            onTap: () {
                              _resetTimer();
                              PlaybackSpeedSheet.show(
                                context,
                                currentSpeed: state.playbackSpeed,
                                onSpeedSelected: widget.onSpeedChanged,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.speed_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${state.playbackSpeed}x',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Controls (Rewind 10s, Play/Pause, Forward 10s)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: isCompact ? 28 : 36,
                          color: Colors.white,
                          onPressed: () {
                            _resetTimer();
                            final newPos = state.position -
                                const Duration(seconds: 10);
                            widget.onSeek(
                              newPos < Duration.zero ? Duration.zero : newPos,
                            );
                          },
                          icon: const Icon(Icons.replay_10_rounded),
                        ),
                        SizedBox(width: isCompact ? 16 : 24),
                        GestureDetector(
                          onTap: () {
                            _resetTimer();
                            widget.onTogglePlay();
                          },
                          child: Container(
                            width: isCompact ? 48 : 64,
                            height: isCompact ? 48 : 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: isCompact ? 28 : 38,
                            ),
                          ),
                        ),
                        SizedBox(width: isCompact ? 16 : 24),
                        IconButton(
                          iconSize: isCompact ? 28 : 36,
                          color: Colors.white,
                          onPressed: () {
                            _resetTimer();
                            final newPos = state.position +
                                const Duration(seconds: 10);
                            widget.onSeek(
                              newPos > state.duration
                                  ? state.duration
                                  : newPos,
                            );
                          },
                          icon: const Icon(Icons.forward_10_rounded),
                        ),
                      ],
                    ),

                    // Bottom Controls (Seek Bar + Action Row)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RtlSeekBar(
                          position: state.position,
                          duration: state.duration,
                          showTimeLabels: !isCompact,
                          onSeek: (pos) {
                            _resetTimer();
                            widget.onSeek(pos);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: isCompact ? 10 : 16,
                            right: isCompact ? 10 : 16,
                            bottom: isCompact ? 4 : 12,
                            top: 0,
                          ),
                          child: Row(
                            children: [
                              // Time indicator
                              Text(
                                '${DurationFormatter.format(state.position)} / ${DurationFormatter.format(state.duration)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),

                              // Next Lesson button (shown in fullscreen)
                              if (!isCompact && state.nextLesson != null) ...[
                                OutlinedButton.icon(
                                  onPressed: state.isNextLessonUnlocked
                                      ? () {
                                          _resetTimer();
                                          widget.onNextLesson?.call();
                                        }
                                      : null,
                                  icon: Icon(
                                    state.isNextLessonUnlocked
                                        ? Icons.skip_next_rounded
                                        : Icons.lock_outline_rounded,
                                    size: 15,
                                    color: state.isNextLessonUnlocked
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.4),
                                  ),
                                  label: Text(
                                    l10n.nextLesson,
                                    style: TextStyle(
                                      color: state.isNextLessonUnlocked
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: state.isNextLessonUnlocked
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.2),
                                    ),
                                    backgroundColor: state.isNextLessonUnlocked
                                        ? AppTheme.primary.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Fullscreen Toggle
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _resetTimer();
                                  widget.onToggleFullscreen();
                                },
                                icon: Icon(
                                  state.isFullscreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: isCompact ? 22 : 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (!isCompact) {
                  return SafeArea(child: content);
                }
                return content;
              },
            ),
          ),
        ),
      ),
    );
  }
}
