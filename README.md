# ⚡ FitPulse — Futuristic Fitness + Events App

A complete Flutter application with Firebase backend featuring a stunning neon dark UI.

---

## 📱 Screenshots Overview

| Screen | Description |
|--------|-------------|
| **Splash** | Animated neon logo with loading bar |
| **Auth** | Login/Signup with glassmorphism cards |
| **Dashboard** | Streak hero, stats grid, weekly bar chart |
| **Events** | Searchable, filterable event cards with API data |
| **Event Detail** | Full detail with registration to Firestore |
| **Activity** | Animated tracker with custom ring painter |
| **Profile** | Achievements, stats, edit profile |

---

## 🎨 Design System

- **Theme**: Deep navy/black `#050A13` backgrounds
- **Accent 1**: Neon Cyan `#00F5FF` — primary actions, highlights
- **Accent 2**: Neon Purple `#BF00FF` — secondary, Yoga category
- **Accent 3**: Neon Pink `#FF006E` — danger, HIIT, stop actions
- **Accent 4**: Neon Green `#00FF88` — success, streaks, Cycling
- **Fonts**: Orbitron (headings), Rajdhani (labels), Exo 2 (body)
- **Cards**: Glassmorphism with `BackdropFilter` blur + border glow

---

## 🏗 Architecture

```
lib/
├── main.dart                  # App entry, Provider setup, Firebase init
├── firebase_options.dart      # Firebase config (replace with yours)
├── theme/
│   └── app_theme.dart        # Colors, typography, ThemeData
├── models/
│   └── models.dart           # UserModel, EventModel, ActivitySession
├── services/
│   ├── auth_service.dart     # Firebase Auth operations
│   └── event_service.dart    # HTTP API + Firestore event CRUD
├── providers/
│   └── providers.dart        # AuthProvider, EventProvider, ActivityProvider
├── screens/
│   ├── auth_screen.dart      # Login / Signup
│   ├── dashboard_screen.dart # Home with stats
│   ├── events_screen.dart    # Discovery + Event detail
│   ├── activity_screen.dart  # Tracker with custom painter
│   ├── profile_screen.dart   # User profile + settings
│   └── main_navigation.dart  # Bottom nav shell
└── widgets/
    └── widgets.dart          # GlassCard, NeonButton, StatCard,
                              # CategoryChip, ShimmerCard, snackbars
```

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Firebase account
- Android Studio / Xcode (for device testing)

### Step 1: Clone & Install Dependencies

```bash
git clone <your-repo>
cd fitpulse
flutter pub get
```

### Step 2: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named `fitpulse`
3. Enable **Authentication** → Email/Password provider
4. Enable **Firestore Database** → Start in production mode
5. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
6. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```
   This auto-generates `lib/firebase_options.dart` — **delete the placeholder file first!**

### Step 3: Add Platform Files

**Android** — Add `google-services.json` to `android/app/`

**iOS** — Add `GoogleService-Info.plist` to `ios/Runner/`

### Step 4: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Step 5: Run the App

```bash
flutter run
```

---

## 🗄 Firestore Collections

```
/users/{uid}
  uid, email, displayName, totalDistance, streak,
  totalWorkouts, totalCalories, createdAt

/registrations/{userId_eventId}
  userId, eventId, eventTitle, eventDate,
  category, registeredAt

/events/{eventId}
  (populated by admin/backend, participants updated on registration)

/activity_sessions/{sessionId}
  userId, type, distance, duration, calories,
  avgPace, date, paceHistory
```

---

## 🎭 Animations

1. **Splash Screen**: Scale + fade-in with ElasticOut curve
2. **Auth Screen**: Floating radial gradient background pulse
3. **Neon Button**: Scale press with glow intensity animation
4. **Activity Ring**: Custom `CustomPainter` rotating arc + dash ring
5. **Live Badge**: Opacity pulse on LIVE indicator
6. **Start/Stop Button**: Scale animation via `SingleTickerProviderStateMixin`
7. **Screen Transitions**: Slide + fade page route transitions
8. **Weekly Chart**: AnimatedContainer height with ElasticOut
9. **Shimmer Loading**: Custom shimmer gradient animation

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Event registration, user profiles |
| `provider` | State management (AuthProvider, EventProvider, ActivityProvider) |
| `http` | Fetch events from external API |
| `google_fonts` | Orbitron, Rajdhani, Exo 2 fonts |
| `cached_network_image` | Event image caching with shimmer placeholders |
| `intl` | Date formatting |

---

## 🧩 Extending the App

### Add Google Sign-In
```dart
// In auth_service.dart
Future<UserModel?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  return await _auth.signInWithCredential(credential);
}
```

### Add Real GPS Tracking
Replace the simulation in `ActivityProvider.startTracking()` with:
```dart
import 'package:geolocator/geolocator.dart';
// Stream position updates and calculate real distance
```

### Swap Events API
Replace the URL in `EventService.fetchEvents()`:
```dart
// Examples:
// 'https://api.active.com/catalog/...'  (Active.com)
// 'https://api.eventbrite.com/v3/...'   (Eventbrite)
// 'https://api.meetup.com/...'          (Meetup)
```

---

## 🤝 Contributing

1. Fork the repo
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — feel free to use in your own projects!
