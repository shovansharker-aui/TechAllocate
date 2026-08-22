# Firebase and Play Services use reflection in places; keep their classes
# intact so shrinking doesn't strip something they need at runtime.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter's own plugin embedding classes.
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter's engine references Google Play's optional "dynamic feature
# delivery" classes even when they're not used, which R8 flags as missing.
# Since this app is sideloaded (not distributed via Play Store dynamic
# features), it's safe to tell R8 to ignore them rather than pull in the
# whole Play Core library just to satisfy a reference we never use.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
