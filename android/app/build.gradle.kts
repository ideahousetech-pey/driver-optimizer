plugins {
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
    }

    buildTypes {
        release {
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
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
}