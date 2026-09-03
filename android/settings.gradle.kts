pluginManagement {
    try {
        val processEnvClass = Class.forName("java.lang.ProcessEnvironment")
        val theEnvField = processEnvClass.getDeclaredField("theEnvironment")
        theEnvField.isAccessible = true
        @Suppress("UNCHECKED_CAST")
        val env = theEnvField.get(null) as MutableMap<String, String>
        env.remove("ANDROID_PREFS_ROOT")

        val theCaseInsensitiveEnvField = processEnvClass.getDeclaredField("theCaseInsensitiveEnvironment")
        theCaseInsensitiveEnvField.isAccessible = true
        @Suppress("UNCHECKED_CAST")
        val ciEnv = theCaseInsensitiveEnvField.get(null) as MutableMap<String, String>
        ciEnv.remove("ANDROID_PREFS_ROOT")
    } catch (_: Throwable) {
    }

    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
