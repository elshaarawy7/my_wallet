import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsState {
  const SettingsState({
    this.isDarkMode = false,
    this.isOnboardingDone = false,
  });

  final bool isDarkMode;
  final bool isOnboardingDone;

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isOnboardingDone,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOnboardingDone: isOnboardingDone ?? this.isOnboardingDone,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> loadSettings() async {
    final isDarkMode = await _repository.isDarkMode();
    final isOnboardingDone = await _repository.isOnboardingDone();
    emit(
      state.copyWith(
        isDarkMode: isDarkMode,
        isOnboardingDone: isOnboardingDone,
      ),
    );
  }

  Future<void> markOnboardingDone() async {
    await _repository.setOnboardingDone(true);
    emit(state.copyWith(isOnboardingDone: true));
  }

  Future<void> toggleTheme(bool value) async {
    await _repository.setDarkMode(value);
    emit(state.copyWith(isDarkMode: value));
  }
}
