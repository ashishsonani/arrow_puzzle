import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AppSettings {
  static late SharedPreferences _prefs;

  static bool _soundEnabled = false;
  static bool _vibrationEnabled = true;
  static bool _autoLockEnabled = false;

  static bool get soundEnabled => _soundEnabled;
  static bool get vibrationEnabled => _vibrationEnabled;
  static bool get autoLockEnabled => _autoLockEnabled;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _soundEnabled = _prefs.getBool('soundEnabled') ?? false;
    _vibrationEnabled = _prefs.getBool('vibrationEnabled') ?? true;
    _autoLockEnabled = _prefs.getBool('autoLockEnabled') ?? false;

    _applyWakelock();
  }

  static Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs.setBool('soundEnabled', value);
  }

  static Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _prefs.setBool('vibrationEnabled', value);
  }

  static Future<void> setAutoLockEnabled(bool value) async {
    _autoLockEnabled = value;
    await _prefs.setBool('autoLockEnabled', value);
    _applyWakelock();
  }

  static void _applyWakelock() {
    if (_autoLockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }
}
