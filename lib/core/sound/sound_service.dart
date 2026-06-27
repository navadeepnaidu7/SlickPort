import 'package:flutter/services.dart';

/// Platform UI sounds — haptics live in [HapticService].
class SoundService {
  SoundService._();

  static Future<void> click() async {
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> flip() async {
    await click();
  }

  static Future<void> longPress() async {
    await click();
  }

  static Future<void> success() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await click();
  }
}