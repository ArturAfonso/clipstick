import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // -----------------------------
  // 🎯 Firebase Configuration
  // -----------------------------
  static String get firebaseApiKey =>
      dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAppId =>
      dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  // -----------------------------
  // 📢 AdMob Configuration
  // -----------------------------
  static String get admobAppIdAndroid =>
      dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';

  static String get admobAppIdIos =>
      dotenv.env['ADMOB_APP_ID_IOS'] ?? '';

  static String get admobBannerUnitIdAndroid =>
      dotenv.env['ADMOB_BANNER_UNIT_ID_ANDROID'] ?? '';

  static String get admobBannerUnitIdIos =>
      dotenv.env['ADMOB_BANNER_UNIT_ID_IOS'] ?? '';

  static String get admobInterstitialUnitIdAndroid =>
      dotenv.env['ADMOB_INTERSTITIAL_UNIT_ID_ANDROID'] ?? '';

  static String get admobInterstitialUnitIdIos =>
      dotenv.env['ADMOB_INTERSTITIAL_UNIT_ID_IOS'] ?? '';

  // -----------------------------
  // ⚙️ General App Configuration
  // -----------------------------
  static String get appVersion =>
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  static bool get debugMode =>
      dotenv.env['DEBUG_MODE'] == 'true';

  // -----------------------------
  // 📱 Helpers automáticos
  // -----------------------------
  static String getAdmobAppId() {
    if (Platform.isIOS) return admobAppIdIos;
    return admobAppIdAndroid;
  }

  static String getAdmobBannerUnitId() {
    if (Platform.isIOS) return admobBannerUnitIdIos;
    return admobBannerUnitIdAndroid;
  }

  static String getAdmobInterstitialUnitId() {
    if (Platform.isIOS) return admobInterstitialUnitIdIos;
    return admobInterstitialUnitIdAndroid;
  }

   // GIFs do tutorial
  static String get tutorialGifReorder =>
      dotenv.env['TUTORIAL_GIF_REORDER'] ?? '';
  static String get tutorialGifTags =>
      dotenv.env['TUTORIAL_GIF_TAGS'] ?? '';
  static String get tutorialGifPin =>
      dotenv.env['TUTORIAL_GIF_PIN'] ?? '';
  static String get tutorialGifSetTag =>
      dotenv.env['TUTORIAL_GIF_SETTAG'] ?? '';
  
  }




//versoao antiga

/* import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  // AdMob Configuration
  static String get admobAppIdAndroid => dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';
  static String get admobAppIdIos => dotenv.env['ADMOB_APP_ID_IOS'] ?? '';
  static String get admobBannerUnitIdAndroid => dotenv.env['ADMOB_BANNER_UNIT_ID_ANDROID'] ?? '';
  static String get admobBannerUnitIdIos => dotenv.env['ADMOB_BANNER_UNIT_ID_IOS'] ?? '';
  static String get admobInterstitialUnitIdAndroid =>
      dotenv.env['ADMOB_INTERSTITIAL_UNIT_ID_ANDROID'] ?? '';
  static String get admobInterstitialUnitIdIos =>
      dotenv.env['ADMOB_INTERSTITIAL_UNIT_ID_IOS'] ?? '';

  // App Configuration
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE'] == 'true';

  // Métodos helper para AdMob baseado na plataforma
  static String getAdmobAppId() {
    // Você pode usar Platform.isAndroid quando implementar
    return admobAppIdAndroid; // Por enquanto, default Android
  }

  static String getAdmobBannerUnitId() {
    return admobBannerUnitIdAndroid; // Por enquanto, default Android
  }

  static String getAdmobInterstitialUnitId() {
    return admobInterstitialUnitIdAndroid; // Por enquanto, default Android
  }
}
 */