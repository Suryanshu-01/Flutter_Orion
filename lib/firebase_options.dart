import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBgbqtl2snt011DlZngvyiWFLXaEvnjpTw',
    appId: '1:3346416636:web:aa0befc58b9640f505e879',
    messagingSenderId: '3346416636',
    projectId: 'orion-cc7de',
    authDomain: 'orion-cc7de.firebaseapp.com',
    storageBucket: 'orion-cc7de.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyvNJ5K9dj6M0sKQVGn_yeBVhfA_uKfao',
    appId: '1:3346416636:android:c49b30418a332e5e05e879',
    messagingSenderId: '3346416636',
    projectId: 'orion-cc7de',
    storageBucket: 'orion-cc7de.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB4jCqvN59_3itLBpL7aY2wt_UolcCzeVI',
    appId: '1:3346416636:ios:0554562362ce5ed705e879',
    messagingSenderId: '3346416636',
    projectId: 'orion-cc7de',
    storageBucket: 'orion-cc7de.firebasestorage.app',
    iosBundleId: 'com.example.orion',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB4jCqvN59_3itLBpL7aY2wt_UolcCzeVI',
    appId: '1:3346416636:ios:0554562362ce5ed705e879',
    messagingSenderId: '3346416636',
    projectId: 'orion-cc7de',
    storageBucket: 'orion-cc7de.firebasestorage.app',
    iosBundleId: 'com.example.orion',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgbqtl2snt011DlZngvyiWFLXaEvnjpTw',
    appId: '1:3346416636:web:5804db1690a2cd0f05e879',
    messagingSenderId: '3346416636',
    projectId: 'orion-cc7de',
    authDomain: 'orion-cc7de.firebaseapp.com',
    storageBucket: 'orion-cc7de.firebasestorage.app',
  );
}
