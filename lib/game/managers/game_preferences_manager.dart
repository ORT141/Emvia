import 'package:shared_preferences/shared_preferences.dart';

class GamePreferencesManager {
  static const String _volumeKey = 'volume';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _soundAskedKey = 'sound_asked';

  double _volume = 0.6;
  bool _soundEnabled = true;
  bool _soundQuestionAnswered = false;

  double get volume => _soundEnabled ? _volume : 0.0;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _save(_volumeKey, _volume);
  }

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    _save(_soundEnabledKey, _soundEnabled);
  }

  bool get soundQuestionAnswered => _soundQuestionAnswered;
  set soundQuestionAnswered(bool value) {
    _soundQuestionAnswered = value;
    _save(_soundAskedKey, _soundQuestionAnswered);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble(_volumeKey) ?? _volume;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? _soundEnabled;
      _soundQuestionAnswered = prefs.getBool(_soundAskedKey) ?? false;
    } catch (_) {}
  }

  Future<void> _save(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (_) {}
  }
}
