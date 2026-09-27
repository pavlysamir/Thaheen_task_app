import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_formatter.dart';

class RtlSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool showTimeLabels;

  const RtlSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.showTimeLabels = true,
  });

  @override
  State<RtlSeekBar> createState() => _RtlSeekBarState();
}

class _RtlSeekBarState extends State<RtlSeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final maxSeconds = widget.duration.inMilliseconds.toDouble();
    final currentSeconds = widget.position.inMilliseconds.toDouble();

    final sliderValue = (_dragValue ?? currentSeconds).clamp(
      0.0,
      maxSeconds > 0 ? maxSeconds : 0.0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppTheme.primaryLight,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            overlayColor: AppTheme.primaryLight.withValues(alpha: 0.2),
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: maxSeconds > 0 ? sliderValue : 0.0,
            max: maxSeconds > 0 ? maxSeconds : 1.0,
            onChanged: maxSeconds > 0
                ? (val) {
                    setState(() {
                      _dragValue = val;
                    });
                  }
                : null,
            onChangeEnd: maxSeconds > 0
                ? (val) {
                    widget.onSeek(Duration(milliseconds: val.toInt()));
                    setState(() {
                      _dragValue = null;
                    });
                  }
                : null,
          ),
        ),
        if (widget.showTimeLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DurationFormatter.format(
                    _dragValue != null
                        ? Duration(milliseconds: _dragValue!.toInt())
                        : widget.position,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DurationFormatter.format(widget.duration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
