buildscript {
    val kotlinVersion by extra("1.9.24")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.5.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Clean build folder
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}