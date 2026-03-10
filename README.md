# AttendTrack — GPS Student Attendance App
### Built for: MANYURA14 | Mobile Computing Project 2026

---

## ⚡ QUICKSTART — 4 Steps to Get Your APK

### STEP 1 — Add your Firebase config
1. Go to https://console.firebase.google.com
2. Open your AttendTrack project
3. Click Settings (⚙️) → Project Settings → Your apps → your Android app
4. Copy the values into `lib/firebase_options.dart`

Also download `google-services.json` and place it at:
```
android/app/google-services.json
```

### STEP 2 — Open in GitHub Codespaces
1. Go to https://github.com/MANYURA14/attendtrack
2. Click green "Code" button → "Codespaces" tab → "Create codespace on main"
3. Wait for the environment to load (~2 minutes)

### STEP 3 — Run these 2 commands in the Codespaces terminal
```bash
flutter pub get
flutter build apk --release
```
Build takes ~5 minutes.

### STEP 4 — Download your APK
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```
Right-click the file → Download → install on your Android phone.

---

## 📱 App Features
- ✅ Student Login & Registration (Firebase Auth)
- ✅ GPS Geofencing — marks attendance only within 80m of classroom
- ✅ Haversine distance calculation
- ✅ Firestore real-time attendance logging
- ✅ Reports screen with attendance rate + history
- ✅ Anti-proxy: GPS verified, auth-bound, duplicate-blocked

## 📁 Project Structure
```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # ⚠️ Fill with YOUR Firebase values
├── screens/
│   ├── auth_wrapper.dart        # Auto-routes login/home
│   ├── login_screen.dart        # Login UI
│   ├── register_screen.dart     # Registration UI  
│   ├── home_screen.dart         # Bottom nav container
│   ├── attendance_screen.dart   # GPS mark attendance
│   └── reports_screen.dart      # Attendance history
└── services/
    ├── auth_service.dart        # Firebase Auth logic
    ├── gps_service.dart         # GPS + Haversine + geofence
    └── attendance_service.dart  # Full attendance flow
```

## 🔥 Firestore Setup
Make sure your Firestore has a `classes` collection with at least one document:
```
classes/{auto-id}
  courseId: "CS301"
  roomName: "Block B, Room 204"
  location: GeoPoint(YOUR_LAT, YOUR_LNG)  ← your classroom GPS
  geofenceRadius: 80
  isActive: true
```
Get your classroom GPS: open Google Maps → right-click classroom → "What's here?"
