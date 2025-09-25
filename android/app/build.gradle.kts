plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    // إضافة Google Services (مطلوب لـ Firebase)
    id("com.google.gms.google-services")
    // إضافة Crashlytics (اختياري)
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.test_athkar_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.test_athkar_app"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf(
            "-Xjvm-default=all",
            "-Xskip-prerelease-check"
        )
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module"
            )
        }
    }
}

dependencies {
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BoM - استخدم أحدث إصدار مستقر
    implementation(platform("com.google.firebase:firebase-bom:33.6.0"))

    // Firebase libraries الأساسية - بدون تحديد إصدارات (BoM يدير ذلك)
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-config-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    
    // إزالة firebase-core المنفصل - هو مدمج في firebase-analytics-ktx

    // WorkManager - للمهام في الخلفية
    implementation("androidx.work:work-runtime-ktx:2.9.1")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")

    // Google Play Services (مطلوب لـ Firebase)
    implementation("com.google.android.gms:play-services-base:18.5.0")
    implementation("com.google.android.gms:play-services-auth:21.2.0")

    // AndroidX Core (للتوافق)
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
}

flutter {
    source = "../.."
}