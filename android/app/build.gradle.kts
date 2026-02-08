plugins {
    id("com.android.application")
    // Google hizmetleri Gradle eklentisini ekleyin
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.oyun_olustur"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.oyun_olustur"
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

dependencies {
    // Firebase BoM'u içe aktarın
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    // Örnek: Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
    // Diğer Firebase ürünleri için: https://firebase.google.com/docs/android/setup#available-libraries
}

flutter {
    source = "../.."
}
