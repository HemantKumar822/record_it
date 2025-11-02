# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Generative AI
-keep class com.google.** { *; }
-dontwarn com.google.**

# Hive
-keep class hive.** { *; }
-keep class * extends hive.** { *; }

# Audio Recording
-keep class com.doubleslash.** { *; }
-keepclassmembers class * {
    native <methods>;
}

# General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Keep source file and line numbers for better stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
