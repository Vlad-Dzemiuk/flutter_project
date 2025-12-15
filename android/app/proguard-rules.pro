# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * {
    public static final *** CREATOR;
}

# Keep Serializable classes
-keepnames class * {
    static final long serialVersionUID;
    !static !transient <fields>;
}

# Keep annotation default values
-keepattributes AnnotationDefault

# Keep line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom exceptions
-keep public class * {
    <init>(...);
}

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google Play Services Auth classes
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.api.client.googleapis.extensions.android.gms.auth.** { *; }

# Keep Drift database classes
-keep class **$Table { *; }
-keep class **$Companion { *; }

# Keep Hive classes
-keep class hive.** { *; }

# Keep secure storage classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep Dio classes
-keep class dio.** { *; }

# Keep Retrofit classes (if used)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

# Keep JSON serialization
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Keep model classes (adjust package name as needed)
-keep class com.example.project.** { *; }

# Keep Google Play Core classes
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.** { *; }

# Keep Google API Client classes
-keep class com.google.api.client.** { *; }
-keep class com.google.api.client.http.** { *; }
-keep class com.google.api.client.http.javanet.** { *; }

# Keep Google Crypto Tink classes
-keep class com.google.crypto.tink.** { *; }

# Keep Joda-Time classes
-keep class org.joda.time.** { *; }

# Keep Joda-Convert classes and annotations
-keep class org.joda.convert.** { *; }
-dontwarn org.joda.convert.**

# Keep Java reflection classes
-keep class java.lang.reflect.** { *; }
-dontwarn java.lang.reflect.AnnotatedType

