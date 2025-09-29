// Placeholder FirebaseOptions. Replace with real values using FlutterFire CLI.
// flutterfire configure --project=<your_project>

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE',
    authDomain: 'REPLACE',
    storageBucket: 'REPLACE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE',
    storageBucket: 'REPLACE',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE',
    storageBucket: 'REPLACE',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}


