plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.project"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.project"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.project"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/java", "src/main/kotlin")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // Code obfuscation для release build
            isMinifyEnabled = true
            isShrinkResources = true

            // ProGuard rules для збереження необхідних класів
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/license.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
            excludes += "META-INF/notice.txt"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Play Core library for split install and deferred components


    // Google API Client libraries for Tink and HTTP transport
    implementation("com.google.crypto.tink:tink-android:1.7.0")
    implementation("com.google.api-client:google-api-client-android:1.33.0")
    implementation("com.google.api-client:google-api-client-gson:1.33.0")

    // Google Play Services Auth for GoogleAuthException and related classes
    implementation("com.google.android.gms:play-services-auth:21.0.0")

    // Joda-Time for org.joda.time.Instant
    implementation("joda-time:joda-time:2.12.7")

    // Joda-Convert for @FromString and @ToString annotations
    implementation("org.joda:joda-convert:2.2.3")
}

configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.google.android.play") {
            when (requested.name) {
                "core" -> useVersion("1.10.3")
                "core-common" -> useVersion("2.0.3")
            }
        }
    }
}
