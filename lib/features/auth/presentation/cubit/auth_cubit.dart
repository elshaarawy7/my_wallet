import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  void startListening() {
    emit(
      state.copyWith(
        status: _repository.currentUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: _repository.currentUser,
      ),
    );

    _subscription ??= _repository.authStateChanges().listen((user) {
      emit(
        state.copyWith(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.login(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'تعذر تسجيل الدخول الآن، حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'تعذر إنشاء الحساب الآن، حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.signInWithGoogle();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'تعذر تسجيل الدخول عبر Google الآن.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
