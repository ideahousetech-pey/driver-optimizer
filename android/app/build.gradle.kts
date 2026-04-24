plugins {
<<<<<<< HEAD
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.driver_optimizer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.driver_optimizer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
=======
    id "com.android.application"
    id "org.jetbrainskotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.driver.optimizer"
    compileSdk 34

    defaultConfig {
        applicationId "com.driver.optimizer"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"

        multiDexEnabled true
>>>>>>> 23b3b788b8d61b37d4a80f58fefae92992f8944e
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
=======
            // Untuk sementara pakai debug signing (aman untuk testing CI)
            signingConfig signingConfigs.debug

            // Aktifkan optimasi nanti kalau sudah stabil
            minifyEnabled false
            shrinkResources false
        }

        debug {
            signingConfig signingConfigs.debug
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    packagingOptions {
        resources {
            excludes += [
                    "META-INF/LICENSE",
                    "META-INF/NOTICE",
                    "META-INF/DEPENDENCIES"
            ]
>>>>>>> 23b3b788b8d61b37d4a80f58fefae92992f8944e
        }
    }
}

flutter {
<<<<<<< HEAD
    source = "../.."
}
=======
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
}
>>>>>>> 23b3b788b8d61b37d4a80f58fefae92992f8944e
