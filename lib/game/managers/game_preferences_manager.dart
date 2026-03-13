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
    _saveVolume();
  }

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    _saveSoundEnabled();
  }

  bool get soundQuestionAnswered => _soundQuestionAnswered;
  set soundQuestionAnswered(bool value) {
    _soundQuestionAnswered = value;
    _saveSoundQuestionAnswered();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble(_volumeKey) ?? _volume;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? _soundEnabled;
      _soundQuestionAnswered = prefs.getBool(_soundAskedKey) ?? false;
    } catch (_) {}
  }

  Future<void> _saveVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeKey, _volume);
    } catch (_) {}
  }

  Future<void> _saveSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
    } catch (_) {}
  }

  Future<void> _saveSoundQuestionAnswered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundAskedKey, _soundQuestionAnswered);
    } catch (_) {}
  }
}
