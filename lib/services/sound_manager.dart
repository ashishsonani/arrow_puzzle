import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';

class SoundManager {
  static final List<AudioPlayer> _clickPlayers = List.generate(5, (_) => AudioPlayer());
  static int _clickPlayerIndex = 0;
  static final AudioPlayer _startPlayer = AudioPlayer();
  static final AudioPlayer _errorPlayer = AudioPlayer();
  static final AudioPlayer _winPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    AudioPlayer.global.setAudioContext(AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build());

    Future.wait([
      ..._clickPlayers.map((p) => p.setReleaseMode(ReleaseMode.stop).then((_) => p.setSourceAsset('click.wav'))),
      _errorPlayer.setReleaseMode(ReleaseMode.stop).then((_) => _errorPlayer.setSourceAsset('error.wav')),
      _startPlayer.setReleaseMode(ReleaseMode.stop).then((_) => _startPlayer.setSourceAsset('start.wav')),
      _winPlayer.setReleaseMode(ReleaseMode.stop).then((_) => _winPlayer.setSourceAsset('win.wav')),
    ]).then((_) {}, onError: (e) {
      debugPrint('SoundManager init note: $e');
    });
  }

  static void playClick() {
    if (!AppSettings.soundEnabled) return;
    try {
      final player = _clickPlayers[_clickPlayerIndex];
      _clickPlayerIndex = (_clickPlayerIndex + 1) % _clickPlayers.length;
      player.stop();
      player.play(AssetSource('click.wav'));
    } catch (e) {
      debugPrint('SoundManager playClick error: $e');
    }
  }

  static void playError() {
    if (!AppSettings.soundEnabled) return;
    try {
      _errorPlayer.stop();
      _errorPlayer.play(AssetSource('error.wav'));
    } catch (e) {
      debugPrint('SoundManager playError error: $e');
    }
  }

  static void playStart() {
    if (!AppSettings.soundEnabled) return;
    try {
      _startPlayer.stop();
      _startPlayer.play(AssetSource('start.wav'));
    } catch (e) {
      debugPrint('SoundManager playStart error: $e');
    }
  }

  static void playWin() {
    if (!AppSettings.soundEnabled) return;
    try {
      _winPlayer.stop();
      _winPlayer.play(AssetSource('win.wav'));
    } catch (e) {
      debugPrint('SoundManager playWin error: $e');
    }
  }
}
