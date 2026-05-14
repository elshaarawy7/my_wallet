abstract class SettingsRepository {
  Future<bool> isDarkMode();

  Future<void> setDarkMode(bool value);

  Future<bool> isOnboardingDone();

  Future<void> setOnboardingDone(bool value);
}
