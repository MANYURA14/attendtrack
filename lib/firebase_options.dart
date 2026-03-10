// ============================================================
// IMPORTANT: Replace the values below with YOUR Firebase config
// How to get these values:
// 1. Go to console.firebase.google.com
// 2. Click your AttendTrack project
// 3. Click Settings (gear icon) → Project Settings
// 4. Scroll down to "Your apps" → click your Android app
// 5. Copy each value shown into the fields below
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  // ⬇️  REPLACE THESE VALUES WITH YOUR OWN FROM FIREBASE CONSOLE
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY_HERE',
    appId: 'YOUR_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_PROJECT_ID_HERE.appspot.com',
  );
}
