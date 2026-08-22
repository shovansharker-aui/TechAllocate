/// Firebase configuration used by the Flutter web build.
///
/// The project ID, API key, sender ID and storage bucket come from the same
/// Firebase project already used by the Android app.
///
/// If Firebase Console gives a different Web App ID after registering a Web
/// app, replace [appId] with that Web App ID. The current Android app ID is
/// used as a fallback so the project can be configured without changing the
/// rest of the application code.
class FirebaseWebConfig {
  static const String apiKey = 'AIzaSyAJLaPHtD63krzm5RI_xHuUiOLvDY059PE';
  static const String appId = '1:450230704371:android:cc153f15e4d960bd343f86';
  static const String messagingSenderId = '450230704371';
  static const String projectId = 'techallocate';
  static const String authDomain = 'techallocate.firebaseapp.com';
  static const String storageBucket = 'techallocate.firebasestorage.app';
}
