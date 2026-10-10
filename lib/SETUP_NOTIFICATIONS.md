# Notification setup

Run `flutter pub get` first, then apply the platform changes below.

## Android

### 1. `android/app/src/main/AndroidManifest.xml`

Add the permissions above `<application>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

Add the receivers **inside** `<application>` (so reminders survive a reboot):

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 2. Core library desugaring (required by the plugin)

`android/app/build.gradle.kts` (newer Flutter templates):

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

`android/app/build.gradle` (older Groovy templates):

```groovy
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
```

## iOS

In `ios/Runner/AppDelegate.swift`, inside `application(_:didFinishLaunchingWithOptions:)`
and **before** `return super.application(...)`, add:

```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

## Notes

- Reminders use inexact scheduling on Android, so they can arrive a few minutes
  late when the phone is in deep sleep. To make them exact, add the
  `USE_EXACT_ALARM` permission to the manifest and change
  `AndroidScheduleMode.inexactAllowWhileIdle` to `exactAllowWhileIdle` in
  `notification_service.dart`.
- Turn reminders on from the app, tap **Send a test notification**, and confirm
  it appears.
