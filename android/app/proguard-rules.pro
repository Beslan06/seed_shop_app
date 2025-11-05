# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Play Core (для исправления ошибки с deferred components)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.review.** { *; }

# Игнорировать предупреждения для Play Core
-dontwarn com.google.android.play.**
-dontwarn com.google.android.gms.**

# Другие библиотеки
-keep class com.example.seed_app.** { *; }

# Дополнительные правила для корректной работы
-keepattributes *Annotation*
-keepclasseswithmembers class * {
    public static void main(java.lang.String[]);
}

# Сохранить нативные методы
-keepclasseswithmembernames class * {
    native <methods>;
}

# Сохранить классы с аннотациями @Keep
-keep @androidx.annotation.Keep class * {*;}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}