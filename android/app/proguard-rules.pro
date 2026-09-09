# --- FLUTTER FRAMEWORK ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- ATRIBUTOS E ANOTAÇÕES ---
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# --- GOOGLE ADMOB & PLAY SERVICES ---
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# --- WORKMANAGER & ROOM DATABASE ---
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.room.**
-dontwarn androidx.work.**

# --- PLUGINS NATIVOS DO PROJETO ---
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class net.nfet.flutter.printing.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }

# --- SYNCFUSION & PDFIUM (pdfrx) ---
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**
-keep class pdfrx.** { *; }

# --- SUPRESSÃO DO PLAY CORE ---
-dontwarn com.google.android.play.core.**