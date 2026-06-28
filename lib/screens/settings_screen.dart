import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';

/// Adjusts audio (speed / pitch / Farnsworth) and haptics. Changes are saved
/// immediately and apply to the next puzzle.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final s = controller.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SliderTile(
              title: 'Character speed',
              value: s.charWpm.toDouble(),
              min: 5,
              max: 40,
              suffix: '${s.charWpm} WPM',
              onChanged: (v) => controller.setCharWpm(v.round()),
            ),
            _SliderTile(
              title: 'Overall speed (Farnsworth)',
              subtitle: s.effectiveWpm >= s.charWpm
                  ? 'No extra spacing'
                  : 'Wider gaps between letters',
              value: s.effectiveWpm.toDouble(),
              min: 5,
              max: s.charWpm.toDouble(),
              suffix: '${s.effectiveWpm} WPM',
              onChanged: (v) => controller.setEffectiveWpm(v.round()),
            ),
            _SliderTile(
              title: 'Tone pitch',
              value: s.toneHz.toDouble(),
              min: 400,
              max: 1000,
              divisions: 12,
              suffix: '${s.toneHz} Hz',
              onChanged: (v) => controller.setToneHz(v.round()),
            ),
            SwitchListTile(
              title: const Text('Haptic playback'),
              subtitle: const Text('Vibrate the pattern alongside audio'),
              value: s.hapticsEnabled,
              onChanged: controller.setHaptics,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Guard against min == max (e.g. Farnsworth at character speed).
    final safeMax = max <= min ? min + 1 : max;
    final safeValue = value.clamp(min, safeMax);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              Text(suffix, style: theme.textTheme.titleMedium),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          Slider(
            value: safeValue,
            min: min,
            max: safeMax,
            divisions: divisions ?? (safeMax - min).round(),
            label: suffix,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
