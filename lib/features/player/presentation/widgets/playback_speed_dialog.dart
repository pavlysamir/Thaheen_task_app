import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';

class PlaybackSpeedSheet extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  static const List<double> availableSpeeds = [1.0, 1.25, 1.5, 2.0];

  const PlaybackSpeedSheet({
    super.key,
    required this.currentSpeed,
    required this.onSpeedSelected,
  });

  static void show(
    BuildContext context, {
    required double currentSpeed,
    required ValueChanged<double> onSpeedSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PlaybackSpeedSheet(
        currentSpeed: currentSpeed,
        onSpeedSelected: (speed) {
          onSpeedSelected(speed);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.playbackSpeed,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...availableSpeeds.map((speed) {
              final isSelected = (currentSpeed - speed).abs() < 0.01;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                ),
                title: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                onTap: () => onSpeedSelected(speed),
              );
            }),
          ],
        ),
      ),
    );
  }
}
