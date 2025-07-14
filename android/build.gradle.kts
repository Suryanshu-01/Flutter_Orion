// File: android/build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    // id("com.google.gms.google-services") version "4.4.1" apply false 
    id("com.google.gms.google-services") version "4.3.15" apply false// ✅ Use exact version here only
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: custom build folder
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
