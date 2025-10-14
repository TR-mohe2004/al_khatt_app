plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ly.alkhatt.app.al_khatt_app"
    // --- ✅ تم تحديث compileSdk إلى 36 كما طلب الخطأ --- 
    compileSdk = 36 
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "ly.alkhatt.app.al_khatt_app"
        minSdk = flutter.minSdkVersion
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

dependencies {
    // --- ✅ تم تحديث إصدار desugar_jdk_libs إلى 2.1.4 كما طلب الخطأ --- 
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
