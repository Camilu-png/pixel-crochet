import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identifiers for each onboarding tip shown across the app.
enum OnboardingTip { import, importImage, projectDirection, projectBlocks }

/// Tracks which onboarding tips a user has already seen, so each tip shows
/// only once per device.
///
/// Under the hood it stores a flat list of seen tip keys in SharedPreferences,
/// keeping the persisted surface small and independent of project data.
class OnboardingStorage {
  static const _seenKey = 'onboarding_seen';

  Future<List<String>> _seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seenKey) ?? const [];
  }

  Future<bool> hasSeen(OnboardingTip tip) async {
    final seen = await _seen();
    return seen.contains(tip.name);
  }

  Future<void> markAsSeen(OnboardingTip tip) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_seenKey) ?? const [];
    if (seen.contains(tip.name)) return;
    prefs.setStringList(_seenKey, [...seen, tip.name]);
  }
}

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});
