// File: build.gradle.kts (root)

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    // Android & Kotlin plugins
    id("com.android.application") version "8.7.3" apply false
    id("com.android.library") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") apply false

    // Firebase - Google Services plugin
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Move the build directory two levels up (custom)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Optional: Ensure :app is evaluated before others (if needed)
subprojects {
    project.evaluationDependsOn(":app")
}

// Custom clean task to clean the custom build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
