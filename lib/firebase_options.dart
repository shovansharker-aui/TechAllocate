// Generated Firebase configuration for TechAllocate.
// Platforms configured for this project: Android and Web.

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB1IXfq_vdqXev-n_u8dgSnSZV-mBc7yuo',
    appId: '1:450230704371:web:0180c9bb97a911f343f86',
    messagingSenderId: '450230704371',
    projectId: 'techallocate',
    authDomain: 'techallocate.firebaseapp.com',
    storageBucket: 'techallocate.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJLaPHtD63krzm5RI_xHuUiOLvDY059PE',
    appId: '1:450230704371:android:cc153f15e4d960bd343f86',
    messagingSenderId: '450230704371',
    projectId: 'techallocate',
    storageBucket: 'techallocate.firebasestorage.app',
  );
}
