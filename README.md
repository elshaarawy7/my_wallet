# My Wallet | محفظتي

تطبيق Flutter عربي لإدارة المصروفات الشهرية بشكل بسيط وحديث مع دعم كامل لـ RTL.

## Features

- تسجيل دخول وإنشاء حساب
- Google Sign-In عبر Firebase Authentication
- حفظ محلي للمصروفات والتصنيفات والشهور باستخدام Hive
- تتبع شهري للمصروفات والميزانية
- إحصائيات ورسوم بيانية باستخدام `fl_chart`
- الوضع الفاتح والداكن
- واجهة عربية حديثة وسهلة للمبتدئين

## Architecture

تم تنظيم المشروع بأسلوب قريب من Clean Architecture:

```text
lib/
  core/
    constants/
    di/
    router/
    services/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    categories/
      data/
      domain/
      presentation/
    expenses/
      data/
      domain/
      presentation/
    home/
      presentation/
    months/
      data/
      domain/
      presentation/
    onboarding/
      presentation/
    profile/
      presentation/
    settings/
      data/
      domain/
      presentation/
    splash/
      presentation/
    statistics/
      presentation/
```

## Packages

- `flutter_bloc`
- `go_router`
- `get_it`
- `firebase_core`
- `firebase_auth`
- `google_sign_in`
- `hive`
- `hive_flutter`
- `shared_preferences`
- `fl_chart`
- `google_fonts`
- `intl`
- `uuid`

## Run Steps

1. افتح المشروع:

```bash
cd D:\flutter_windows_3.38.5-stable\my_projects\my_wallet
```

2. حمّل الحزم:

```bash
flutter pub get
```

3. شغّل التطبيق:

```bash
flutter run
```

## Firebase Setup

1. أنشئ مشروع Firebase جديد من [Firebase Console](https://console.firebase.google.com/).
2. فعّل `Authentication`.
3. فعّل `Email/Password`.
4. فعّل `Google Sign-In`.
5. ثبّت FlutterFire CLI إذا لم تكن مثبتة:

```bash
dart pub global activate flutterfire_cli
```

6. من داخل المشروع شغّل:

```bash
flutterfire configure
```

7. تأكد من إنشاء أو تحديث الملفات التالية:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

8. على Android:
- أضف SHA-1 و SHA-256 داخل Firebase Project Settings.
- تأكد من اسم الحزمة في `android/app/build.gradle.kts` أو `build.gradle`.

9. على iOS:
- افتح `ios/Runner.xcworkspace`.
- تأكد من `Bundle Identifier`.

10. بعد الإعداد أعد تشغيل:

```bash
flutter clean
flutter pub get
flutter run
```

## Git Workflow Suggested

- `feat: bootstrap clean architecture app shell`
- `feat: add firebase auth flow`
- `feat: add home and expense management`
- `feat: add months and statistics screens`
- `ui: polish arabic rtl experience`

## Notes

- التطبيق يعمل كواجهة كاملة مع تخزين محلي حتى قبل إنهاء إعداد Firebase.
- تسجيل الدخول الحقيقي عبر Firebase وGoogle يحتاج تنفيذ الخطوات السابقة.
