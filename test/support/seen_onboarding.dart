import 'package:pixel_crochet/core/onboarding/onboarding_provider.dart';

/// Onboarding that has already been shown, so the tutorial overlay never sits
/// over the controls under test.
class SeenOnboarding extends OnboardingStorage {
  @override
  Future<bool> hasSeen(OnboardingTip tip) async => true;

  @override
  Future<void> markAsSeen(OnboardingTip tip) async {}
}
