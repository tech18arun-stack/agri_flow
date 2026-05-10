# Add project specific ProGuard rules here.
# By default, the flags in Flutter's default ProGuard rules are already included.

# Keep model classes
-keep class * implements com.google.gson.TypeAdapter
-keep class * { @com.google.gson.annotations.SerializedName <fields>; }

# Keep Appwrite
-keep class io.appwrite.** { *; }
-dontwarn io.appwrite.**

# Keep Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Google Play Core classes (for Flutter Play Store features)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**

# Keep location services
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Keep network calls
-keepattributes Signature, *Annotation*
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep model classes for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
