import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Replace these placeholder values by running `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:web:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'replace-me',
    authDomain: 'replace-me.firebaseapp.com',
    storageBucket: 'replace-me.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:android:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'replace-me',
    storageBucket: 'replace-me.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:ios:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'replace-me',
    iosBundleId: 'com.example.myWallet',
    storageBucket: 'replace-me.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:web:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'replace-me',
    authDomain: 'replace-me.firebaseapp.com',
    storageBucket: 'replace-me.appspot.com',
  );
}
