import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadProperties = Properties()
val uploadPropertiesFile = rootProject.file("key.properties")
if (uploadPropertiesFile.isFile) {
    uploadPropertiesFile.inputStream().use { uploadProperties.load(it) }
}

// Keep credentials local; Gradle properties and environment variables support CI.
val uploadSigningValues = listOf(
    "MYAPP_UPLOAD_STORE_FILE",
    "MYAPP_UPLOAD_KEY_ALIAS",
    "MYAPP_UPLOAD_STORE_PASSWORD",
    "MYAPP_UPLOAD_KEY_PASSWORD",
).associateWith { name ->
    (providers.gradleProperty(name)
        .orElse(providers.environmentVariable(name))
        .orNull ?: uploadProperties.getProperty(name))?.takeIf { it.isNotBlank() }
}
// Relative keystore paths resolve from android/app, matching the supplied key.
val uploadStoreFile = uploadSigningValues["MYAPP_UPLOAD_STORE_FILE"]?.let { file(it) }

val validateReleaseSigning by tasks.registering {
    group = "verification"
    description = "Checks the upload keystore configuration for release builds."
    doLast {
        val missing = uploadSigningValues.filterValues { it == null }.keys
        if (missing.isNotEmpty()) {
            throw GradleException(
                "Missing Android release signing properties: ${missing.joinToString()}. " +
                    "Configure android/key.properties using key.properties.example, " +
                    "or supply Gradle properties/environment variables.",
            )
        }
        if (uploadStoreFile?.isFile != true) {
            throw GradleException(
                "Upload keystore not found: $uploadStoreFile. " +
                    "MYAPP_UPLOAD_STORE_FILE is relative to android/app or absolute.",
            )
        }
    }
}

android {
    namespace = "com.up5.upbrainquest"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.up5.upbrainquest"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = uploadStoreFile
            keyAlias = uploadSigningValues["MYAPP_UPLOAD_KEY_ALIAS"]
            storePassword = uploadSigningValues["MYAPP_UPLOAD_STORE_PASSWORD"]
            keyPassword = uploadSigningValues["MYAPP_UPLOAD_KEY_PASSWORD"]
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" || it.name == "validateSigningRelease" }
    .configureEach { dependsOn(validateReleaseSigning) }

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
