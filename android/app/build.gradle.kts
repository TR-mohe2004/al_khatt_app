plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ly.alkhatt.app.al_khatt_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // <---  هذا هو السطر الذي يتم تصحيحه في كل مرة ننشا كود فاير بيز جديد ندرو ربط هكي

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ly.alkhatt.app.al_khatt_app"
        // 👇 هنا غيرنا minSdk من flutter.minSdkVersion إلى 23
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
