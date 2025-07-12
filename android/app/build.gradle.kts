plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ Kotlin plugin
    id("dev.flutter.flutter-gradle-plugin") // ✅ Flutter
    id("com.google.gms.google-services") // ✅ Firebase plugin
}

android {
    namespace = "com.example.orion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13599879"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.orion"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Replace later with release key
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BOM manages all Firebase versions together
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // ✅ Firebase SDKs you are using
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-database")
    implementation("com.google.firebase:firebase-analytics")

    // (Optional) Add others like Firestore, Messaging, etc.
}
