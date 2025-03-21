// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBugN17IO5TD_hiSbeanvuzhvSgHNtzCjQ',
    appId: '1:647537760977:web:8a5d4bc101129db63683f0',
    messagingSenderId: '647537760977',
    projectId: 'examgo-5171e',
    authDomain: 'examgo-5171e.firebaseapp.com',
    storageBucket: 'examgo-5171e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhu7CLrbdizh2puM34foaH2mE1do-q5Oc',
    appId: '1:647537760977:android:26031a7218e1bf503683f0',
    messagingSenderId: '647537760977',
    projectId: 'examgo-5171e',
    storageBucket: 'examgo-5171e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5KKCxQB3ds5XXHWmGIJIyA-IMZ0X56-s',
    appId: '1:647537760977:ios:b3289aea383e2b363683f0',
    messagingSenderId: '647537760977',
    projectId: 'examgo-5171e',
    storageBucket: 'examgo-5171e.firebasestorage.app',
    iosBundleId: 'com.example.examgo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5KKCxQB3ds5XXHWmGIJIyA-IMZ0X56-s',
    appId: '1:647537760977:ios:b3289aea383e2b363683f0',
    messagingSenderId: '647537760977',
    projectId: 'examgo-5171e',
    storageBucket: 'examgo-5171e.firebasestorage.app',
    iosBundleId: 'com.example.examgo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBugN17IO5TD_hiSbeanvuzhvSgHNtzCjQ',
    appId: '1:647537760977:web:e0d3147a001a168d3683f0',
    messagingSenderId: '647537760977',
    projectId: 'examgo-5171e',
    authDomain: 'examgo-5171e.firebaseapp.com',
    storageBucket: 'examgo-5171e.firebasestorage.app',
  );
}
