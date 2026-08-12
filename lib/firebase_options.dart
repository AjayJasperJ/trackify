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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBEyjrqt8HGO0KEiCxMPxCnGCU4jGy-TnU',
    appId: '1:574166626839:web:784ffa98ada3d93dc56252',
    messagingSenderId: '574166626839',
    projectId: 'trackify2196',
    authDomain: 'trackify2196.firebaseapp.com',
    storageBucket: 'trackify2196.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRT6QH58WWKYSuTsDf7UgOsQKFeiHMSz0',
    appId: '1:574166626839:android:cab141c37d7ba1ecc56252',
    messagingSenderId: '574166626839',
    projectId: 'trackify2196',
    storageBucket: 'trackify2196.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_n17u-fS_bbtAWxrZuP4xOJma_nazrdc',
    appId: '1:574166626839:ios:ad7da093b31aaa88c56252',
    messagingSenderId: '574166626839',
    projectId: 'trackify2196',
    storageBucket: 'trackify2196.firebasestorage.app',
    iosBundleId: 'com.trackify.jaspr',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_n17u-fS_bbtAWxrZuP4xOJma_nazrdc',
    appId: '1:574166626839:ios:ad7da093b31aaa88c56252',
    messagingSenderId: '574166626839',
    projectId: 'trackify2196',
    storageBucket: 'trackify2196.firebasestorage.app',
    iosBundleId: 'com.trackify.jaspr',
  );
}
