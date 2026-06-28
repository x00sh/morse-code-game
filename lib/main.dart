import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/audio_player_service.dart';
import 'services/content_repository.dart';
import 'services/haptic_service.dart';
import 'services/settings_repository.dart';
import 'state/game_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepo = SettingsRepository();
  final settings = SettingsController(settingsRepo);
  await settings.load();

  final audio = AudioPlayerService();
  await audio.init();

  final game = GameController(
    content: ContentRepository(),
    audio: audio,
    haptic: HapticService(),
    settings: settings,
    settingsRepo: settingsRepo,
  );
  await game.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<GameController>.value(value: game),
      ],
      child: const MorseApp(),
    ),
  );
}
