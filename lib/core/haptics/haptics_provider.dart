import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'haptic_service.dart';

const _kHapticsEnabledKey = 'haptics_enabled';

final hapticsEnabledProvider = StateNotifierProvider<HapticsEnabledNotifier, bool>(
  (ref) => HapticsEnabledNotifier(),
);

class HapticsEnabledNotifier extends StateNotifier<bool> {
  HapticsEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool value = prefs.getBool(_kHapticsEnabledKey) ?? true;
    state = value;
    HapticService.enabled = value;
  }

  Future<void> toggle() async {
    state = !state;
    HapticService.enabled = state;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHapticsEnabledKey, state);
    if (state) {
      await HapticService.tap();
    }
  }
}