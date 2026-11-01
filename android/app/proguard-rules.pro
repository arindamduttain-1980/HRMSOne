# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Google ML Kit Face Detection & Vision
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.android.gms.internal.mlkit_**
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**
-keep class com.google_mlkit_commons.** { *; }
-dontwarn com.google_mlkit_commons.**
-keep class com.google_mlkit_face_detection.** { *; }
-dontwarn com.google_mlkit_face_detection.**

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class com.tflite.** { *; }
-dontwarn com.tflite.**
-keep class tflite_flutter.** { *; }
-dontwarn tflite_flutter.**

# Camera plugin
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Secure Storage & SQLite
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Preserve all native JNI methods
-keepclasseswithmembernames class * {
    native <methods>;
}

