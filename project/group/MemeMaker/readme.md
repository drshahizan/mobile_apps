# WorkBeacon By MemeMaker

MemeMaker consist of:
1)	MUHAMAD ARIF BIN JOHAR (SX211702ECRHF04) 
2)	MOHAMED FIRDAUS BIN ZAIDI (SX200604ECJHS04)
3)	MUHAMMAD HIZWAN BIN ZAMERI (SX211682ECJHF03)
4)	MUHAMMAD HAZIM BIN ADNAN (SX200750ECJHS04)

For SECJ3623 PENGATURCARAAN APLIKASI MOBIL 2025/2026-01

GitHub Repo link: [:octocat:] https://github.com/hizwanzameri/work_beacon

A Flutter mobile app for workplace safety, incident reporting, and staff location visibility. **WorkBeacon** lets staff report incidents (with photos and categories) and view alerts, while admins can manage incidents, send alerts, browse a staff directory, and view live staff locations on a map.

## Features

### Staff
- **Dashboard** — Overview and quick access to alerts and incidents
- **Report incident** — Submit incidents with category, description, location, and photo (camera or gallery)
- **Incidents** — View and track reported incidents
- **Alert history & details** — See alerts sent by admins
- **Profile** — View and edit profile information

### Admin
- **Dashboard** — Central hub with navigation to all admin tools
- **All incidents** — View and manage all staff-reported incidents
- **Send alerts** — Broadcast alerts to staff
- **Staff directory** — Browse staff list and details
- **Live locations** — Map view of staff locations (with optional Mapbox tiles)

## Tech stack

- **Flutter** (SDK ^3.9.2)
- **Firebase** — Authentication, Cloud Firestore, Storage
- **Maps** — `flutter_map` with `latlong2`; optional Mapbox tiles via `.env`
- **Other** — `image_picker`, `flutter_dotenv`

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- A [Firebase](https://console.firebase.google.com/) project with:
  - Authentication (e.g. Email/Password) enabled
  - Cloud Firestore and Storage configured
  - Android/iOS apps registered and config files in place (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

## Setup

1. **Clone and install**
   ```bash
   git clone <repository-url>
   cd work_beacon
   flutter pub get
   ```

2. **Firebase**
   - Create a Firebase project and add Android/iOS apps if needed
   - Download and place:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist` (if building for iOS)
   - Ensure Firestore and Storage rules and indexes match your app’s usage

3. **Environment (optional — for Mapbox map tiles)**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and set your [Mapbox access token](https://account.mapbox.com/):
   ```
   MAPBOX_ACCESS_TOKEN=pk.your_mapbox_public_token_here
   ```
   The app runs without `.env`; maps will use default/open tiles if no token is set.

4. **Run**
   ```bash
   flutter run
   ```

## Project structure

```
lib/
├── main.dart                 # App entry, Firebase init, routes
├── login/
│   └── login.dart            # Login screen (email/password)
├── screens/
│   ├── admin/                # Admin dashboard, incidents, alerts, directory, live map
│   ├── staff/                # Staff dashboard, incidents, alerts, profile, report incident
│   └── signup/
│       └── sign_up.dart      # Registration
├── services/
│   └── profile_service.dart  # User profile (Firestore)
└── widgets/
    └── incident_card.dart    # Reusable incident card
```

## Configuration

| Item | Description |
|------|-------------|
| `.env` | Optional; copy from `.env.example`. Used for `MAPBOX_ACCESS_TOKEN`. |
| `firestore.rules` | Firestore security rules |
| `storage.rules` | Firebase Storage rules |

## Building for release

- **Android:** `flutter build apk` or `flutter build appbundle`
- **iOS:** `flutter build ios` (then archive in Xcode)

## License

Private/educational use. See repository or project owners for terms.

