<<<<<<< HEAD
=======
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

>>>>>>> 23b3b788b8d61b37d4a80f58fefae92992f8944e
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

<<<<<<< HEAD
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
=======
// Clean build folder
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
>>>>>>> 23b3b788b8d61b37d4a80f58fefae92992f8944e
