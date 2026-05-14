import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsLocalRepository implements SettingsRepository {
  SettingsLocalRepository(this._prefsService);

  final SharedPrefsService _prefsService;

  @override
  Future<bool> isDarkMode() async {
    return _prefsService.getBool(AppConstants.darkModeKey);
  }

  @override
  Future<bool> isOnboardingDone() async {
    return _prefsService.getBool(AppConstants.onboardingKey);
  }

  @override
  Future<void> setDarkMode(bool value) async {
    await _prefsService.setBool(AppConstants.darkModeKey, value);
  }

  @override
  Future<void> setOnboardingDone(bool value) async {
    await _prefsService.setBool(AppConstants.onboardingKey, value);
  }
}
