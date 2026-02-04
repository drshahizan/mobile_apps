# Engineering Store - Quick Reference Guide

## ⚡ Developer Quick Reference

**Last Updated**: February 4, 2026  
**Version**: 1.0

---

## 📋 Table of Contents

1. [Common Commands](#common-commands)
2. [Firebase Commands](#firebase-commands)
3. [Code Snippets](#code-snippets)
4. [Firestore Queries](#firestore-queries)
5. [Troubleshooting](#troubleshooting)
6. [File Locations](#file-locations)
7. [Keyboard Shortcuts](#keyboard-shortcuts)

---

## Common Commands

### Flutter Commands

#### **Project Setup**
```bash
# Navigate to project
cd "C:\Users\SYAZWAN\OneDrive\Documents\GitHub\mobile_apps\project\group\DevX\engineering_store"

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Show outdated packages
flutter pub outdated
```

#### **Running the App**
```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_5_API_34
```

#### **Building**
```bash
# Clean build files
flutter clean

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build app bundle
flutter build appbundle
```

#### **Testing**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

#### **Code Quality**
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Format specific file
dart format lib/main.dart
```

#### **Logs & Debugging**
```bash
# View logs
flutter logs

# Verbose logging
flutter run -v

# Clear logs
flutter logs --clear
```

---

## Firebase Commands

### FlutterFire CLI

#### **Installation**
```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Check version
flutterfire --version
```

#### **Configuration**
```bash
# Configure Firebase for project
flutterfire configure

# Configure for Android only
flutterfire configure --platforms=android

# Configure with specific project
flutterfire configure --project=<project-id>
```

#### **Firebase CLI**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# List projects
firebase projects:list

# Select project
firebase use <project-id>

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy all
firebase deploy
```

---

## Code Snippets

### Authentication

#### **Sign In**
```dart
import 'package:firebase_auth/firebase_auth.dart';

try {
  UserCredential userCredential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  print('Signed in: ${userCredential.user?.email}');
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    print('No user found for that email.');
  } else if (e.code == 'wrong-password') {
    print('Wrong password provided.');
  }
}
```

#### **Sign Out**
```dart
await FirebaseAuth.instance.signOut();
```

#### **Get Current User**
```dart
User? user = FirebaseAuth.instance.currentUser;
if (user != null) {
  print('User: ${user.email}');
}
```

#### **Auth State Listener**
```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User is signed out');
  } else {
    print('User is signed in');
  }
});
```

---

### Firestore Operations

#### **Add Document**
```dart
await FirebaseFirestore.instance.collection('inventory').add({
  'sapCode': '7000001',
  'name': 'Bearing',
  'currentStock': 100,
  'timestamp': FieldValue.serverTimestamp(),
});
```

#### **Add Document with ID**
```dart
await FirebaseFirestore.instance
    .collection('inventory')
    .doc('item123')
    .set({
  'sapCode': '7000001',
  'name': 'Bearing',
});
```

#### **Update Document**
```dart
await FirebaseFirestore.instance
    .collection('inventory')
    .doc('item123')
    .update({
  'currentStock': 150,
  'lastUpdated': FieldValue.serverTimestamp(),
});
```

#### **Delete Document**
```dart
await FirebaseFirestore.instance
    .collection('inventory')
    .doc('item123')
    .delete();
```

#### **Get Single Document**
```dart
DocumentSnapshot doc = await FirebaseFirestore.instance
    .collection('inventory')
    .doc('item123')
    .get();

if (doc.exists) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  print('Item: ${data['name']}');
}
```

#### **Get All Documents**
```dart
QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection('inventory')
    .get();

for (var doc in querySnapshot.docs) {
  print('${doc.id} => ${doc.data()}');
}
```

#### **Real-time Listener**
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var doc = snapshot.data!.docs[index];
        return ListTile(
          title: Text(doc['name']),
          subtitle: Text('Stock: ${doc['currentStock']}'),
        );
      },
    );
  },
)
```

---

## Firestore Queries

### Basic Queries

#### **Where Clause**
```dart
// Get items with low stock
FirebaseFirestore.instance
    .collection('inventory')
    .where('currentStock', isLessThan: 5)
    .get();
```

#### **Order By**
```dart
// Get items ordered by name
FirebaseFirestore.instance
    .collection('inventory')
    .orderBy('name', descending: false)
    .get();
```

#### **Limit**
```dart
// Get first 10 items
FirebaseFirestore.instance
    .collection('inventory')
    .limit(10)
    .get();
```

#### **Multiple Conditions**
```dart
// Get low stock items ordered by name
FirebaseFirestore.instance
    .collection('inventory')
    .where('currentStock', isLessThan: 5)
    .orderBy('currentStock')
    .orderBy('name')
    .get();
```

#### **Array Contains**
```dart
// Get items by category
FirebaseFirestore.instance
    .collection('inventory')
    .where('categories', arrayContains: 'electronics')
    .get();
```

---

### Advanced Queries

#### **Compound Query**
```dart
FirebaseFirestore.instance
    .collection('inventory')
    .where('currentStock', isGreaterThan: 0)
    .where('currentStock', isLessThan: 10)
    .orderBy('currentStock')
    .get();
```

#### **In Query**
```dart
FirebaseFirestore.instance
    .collection('inventory')
    .where('sapCode', whereIn: ['7000001', '7000002', '7000003'])
    .get();
```

#### **Not In Query**
```dart
FirebaseFirestore.instance
    .collection('inventory')
    .where('rackNumber', whereNotIn: ['A', 'B'])
    .get();
```

---

### Combining Streams (RxDart)

```dart
import 'package:rxdart/rxdart.dart';

Stream<List<dynamic>> combinedStream = Rx.combineLatest2(
  FirebaseFirestore.instance.collection('receivings').snapshots(),
  FirebaseFirestore.instance.collection('issuance').snapshots(),
  (QuerySnapshot receivings, QuerySnapshot issuance) {
    List<dynamic> combined = [];
    combined.addAll(receivings.docs);
    combined.addAll(issuance.docs);
    return combined;
  },
);
```

---

## Troubleshooting

### Common Issues

#### **Issue**: Items not appearing in list
**Solution**:
```bash
# Check Firestore connection
flutter logs | grep -i firestore

# Verify security rules in Firebase Console
# Check if user is authenticated
# Ensure internet connection is active
```

#### **Issue**: Build failed
**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### **Issue**: Google services error
**Solution**:
```bash
# Verify google-services.json exists
ls android/app/google-services.json

# Reconfigure Firebase
flutterfire configure --platforms=android
```

#### **Issue**: Real-time updates not working
**Solution**:
```dart
// Check StreamBuilder error handling
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      print('Stream error: ${snapshot.error}');
      return Text('Error: ${snapshot.error}');
    }
    // ... rest of builder
  },
)
```

#### **Issue**: Permission denied error
**Solution**:
1. Check Firestore security rules
2. Verify user is authenticated
3. Check user role permissions
4. Test in Firebase Console Rules playground

---

### Quick Fixes

#### **Reset Flutter**
```bash
flutter doctor
flutter clean
flutter pub get
```

#### **Clear App Data on Emulator**
```bash
adb shell pm clear com.example.engineering_store
```

#### **Restart ADB**
```bash
adb kill-server
adb start-server
```

#### **Check Flutter Version**
```bash
flutter --version
flutter doctor -v
```

---

## File Locations

### Important Files

```
Project Structure:
├── lib/
│   ├── main.dart                          # App entry point
│   ├── screens/
│   │   ├── login_screen.dart             # Authentication
│   │   ├── home_screen.dart              # Dashboard
│   │   ├── inventory_list_screen.dart    # Inventory list
│   │   ├── add_item_screen.dart          # Add items
│   │   ├── receive_item_screen.dart      # Receive transactions
│   │   └── issue_item_screen.dart        # Issue transactions
│   ├── services/
│   │   ├── auth_service.dart             # Auth logic
│   │   ├── firebase_service.dart         # Firebase init
│   │   └── inventory_service.dart        # Inventory logic
│   └── widgets/
│       └── home_action.dart              # Reusable widgets
├── android/
│   └── app/
│       ├── google-services.json          # Firebase config
│       └── build.gradle.kts              # Android build
└── pubspec.yaml                          # Dependencies
```

### Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| pubspec.yaml | Root | Dependencies & assets |
| google-services.json | android/app/ | Firebase configuration |
| build.gradle.kts | android/app/ | Android build settings |
| analysis_options.yaml | Root | Linting rules |

---

## Keyboard Shortcuts

### VS Code

| Shortcut | Action |
|----------|--------|
| `Ctrl + Space` | Autocomplete |
| `Ctrl + .` | Quick fix |
| `F5` | Start debugging |
| `Shift + F5` | Stop debugging |
| `Ctrl + Shift + R` | Hot reload |
| `Ctrl + F5` | Run without debugging |
| `Ctrl + Shift + F` | Format document |
| `F12` | Go to definition |
| `Ctrl + Click` | Go to definition |
| `Alt + ←` | Go back |
| `Alt + →` | Go forward |

### Android Studio

| Shortcut | Action |
|----------|--------|
| `Ctrl + Alt + L` | Format code |
| `Shift + F10` | Run app |
| `Shift + F9` | Debug app |
| `Ctrl + F9` | Build project |
| `Ctrl + Alt + Y` | Reload |
| `Double Shift` | Search everywhere |
| `Ctrl + N` | Find class |
| `Ctrl + Shift + N` | Find file |

---

## Environment Variables

### Flutter Environment
```bash
# Check Flutter path
echo $FLUTTER_ROOT

# Check Dart path
echo $DART_SDK

# Check Android SDK path
echo $ANDROID_HOME
```

---

## Database Quick Reference

### Field Types

| Dart Type | Firestore Type | Example |
|-----------|---------------|---------|
| `String` | string | `"Item Name"` |
| `int` / `double` | number | `100` / `10.5` |
| `bool` | boolean | `true` / `false` |
| `List` | array | `['A', 'B', 'C']` |
| `Map` | map | `{'key': 'value'}` |
| `Timestamp` | timestamp | `FieldValue.serverTimestamp()` |

---

## Security Rules Quick Reference

### Common Patterns

#### **Authenticated Users Only**
```javascript
allow read, write: if request.auth != null;
```

#### **User-specific Data**
```javascript
allow read, write: if request.auth.uid == userId;
```

#### **Admin Only**
```javascript
allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userGroup == 'A';
```

#### **Field Validation**
```javascript
allow create: if request.resource.data.keys().hasAll(['name', 'sapCode']) 
              && request.resource.data.name is string;
```

---

## Git Commands

### Common Operations
```bash
# Check status
git status

# Add files
git add .

# Commit changes
git commit -m "Description"

# Push to remote
git push origin main

# Pull latest
git pull origin main

# Create branch
git checkout -b feature-name

# Switch branch
git checkout main

# View log
git log --oneline
```

---

## Quick Testing Commands

### Manual Testing
```bash
# Run app and check logs
flutter run & flutter logs

# Run with verbose output
flutter run -v

# Run on specific device
flutter run -d emulator-5554
```

### Performance
```bash
# Profile mode
flutter run --profile

# Analyze bundle size
flutter build apk --analyze-size

# Check performance
flutter run --trace-startup
```

---

## Useful URLs

| Resource | URL |
|----------|-----|
| Firebase Console | https://console.firebase.google.com |
| Flutter Docs | https://docs.flutter.dev |
| Pub.dev | https://pub.dev |
| GitHub Repo | (Your repository URL) |
| Stack Overflow | https://stackoverflow.com/questions/tagged/flutter |

---

## Package Versions

**Current Versions** (as of Feb 4, 2026):
```yaml
flutter: 3.35.6
dart: 3.5.4
firebase_core: 2.24.0
firebase_auth: 4.19.0
cloud_firestore: 4.17.0
provider: 6.0.5
rxdart: 0.27.0
```

---

## Quick Contact

**Development Team**: DevX Development Team  
**Documentation**: See `/Project Document` folder  
**Issues**: Create GitHub issue or contact team

---

**Version**: 1.0  
**Last Updated**: February 4, 2026

*Keep this guide handy for quick reference during development!*
