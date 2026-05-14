import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth? firebaseAuth,
    required GoogleSignIn? googleSignIn,
    required bool firebaseReady,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firebaseReady = firebaseReady;

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final bool _firebaseReady;

  @override
  Stream<AppUser?> authStateChanges() {
    if (!_firebaseReady) {
      return Stream.value(null);
    }

    return _firebaseAuth!.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? get currentUser => _mapUser(_firebaseAuth?.currentUser);

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    _ensureFirebase();
    final credential = await _firebaseAuth!.signInWithEmailAndPassword(
      // `_ensureFirebase` guarantees the instance is available here.
      email: email,
      password: password,
    );
    return _mapUser(credential.user)!;
  }

  @override
  Future<void> logout() async {
    if (!_firebaseReady) {
      return;
    }

    await _firebaseAuth?.signOut();
    await _googleSignIn?.signOut();
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureFirebase();
    final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    return _mapUser(_firebaseAuth!.currentUser)!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    _ensureFirebase();

    final googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) {
      throw const AuthException('تم إلغاء تسجيل الدخول عبر Google.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth!.signInWithCredential(credential);
    return _mapUser(userCredential.user)!;
  }

  void _ensureFirebase() {
    if (!_firebaseReady || _firebaseAuth == null || _googleSignIn == null) {
      throw const AuthException(
        'Firebase غير مفعّل بعد. أكمل خطوات الإعداد أولًا.',
      );
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!
          : 'مستخدم جديد',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
