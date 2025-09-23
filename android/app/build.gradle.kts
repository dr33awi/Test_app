plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    
    // Firebase plugins - يجب أن تكون في النهاية
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.test_athkar_app"
    compileSdk = 36
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
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // تأكد من استخدام توقيع الإصدار الصحيح هنا في الإنتاج

            // ✅ تفعيل تقليص الموارد لتقليل حجم التطبيق
            isMinifyEnabled = true // يجب تفعيل هذا أيضًا لاستخدام ProGuard/R8
            isShrinkResources = true // تفعيل تقليص الموارد
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // Firebase BoM - يدير إصدارات جميع Firebase libraries
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    
    // Firebase libraries (بدون تحديد الإصدار - BoM يدير ذلك)
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-config-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    implementation("com.google.firebase:firebase-core")
    
    // WorkManager for background tasks
    implementation("androidx.work:work-runtime-ktx:2.9.1")
}

flutter {
    source = "../.."
}