# Engineering Store - Integration Summary

## 🔌 System Integration Documentation

**Project**: Engineering Store - Inventory Management System  
**Version**: 0.1.0+1  
**Last Updated**: February 4, 2026

---

## Overview

This document provides comprehensive details about all third-party integrations, services, and APIs used in the Engineering Store application. It covers Firebase services, packages, and external dependencies.

---

## Table of Contents

1. [Firebase Integration](#1-firebase-integration)
2. [Flutter Packages](#2-flutter-packages)
3. [Service Architecture](#3-service-architecture)
4. [API Integration](#4-api-integration)
5. [Configuration Files](#5-configuration-files)
6. [Security Implementation](#6-security-implementation)
7. [Data Flow](#7-data-flow)

---

## 1. Firebase Integration

### 1.1 Firebase Project Setup

**Project Details**:
- **Project Name**: Engineering Store
- **Project ID**: `<your-project-id>`
- **Platform**: Android
- **Region**: Default (US)
- **Plan**: Spark (Free Tier)

**Services Used**:
- ✅ Firebase Authentication
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase App Check
- ❌ Firebase Analytics (not implemented)
- ❌ Firebase Cloud Messaging (not implemented)
- ❌ Firebase Crashlytics (not implemented)

---

### 1.2 Firebase Authentication

**Package**: `firebase_auth: ^4.19.0`

**Configuration**:
```dart
// main.dart
await Firebase.initializeApp();
await FirebaseAuth.instance.setSettings(
  appVerificationDisabledForTesting: true
);
```

**Features Implemented**:
- Email/password authentication
- User session management
- Password reset via email
- Auth state change listeners
- Auto-login on valid session

**Authentication Flow**:
```
User Input → AuthService → Firebase Auth → Firestore User Profile
```

**Auth Service Methods**:
```dart
// lib/services/auth_service.dart
class AuthService {
  Stream<User?> authStateChanges()
  Future<UserCredential> signInWithEmail(String email, String password)
  Future<void> signOut()
  Future<DocumentSnapshot> getUserProfile(String uid)
  Stream<DocumentSnapshot> userProfileStream(String uid)
  Future<void> createUserProfile({required String uid, email, displayName})
  Future<void> updateLastLogin(String uid)
  Future<void> updateUserRole(String uid, String role)
}
```

**Security Considerations**:
- reCAPTCHA disabled for development (Android emulator)
- Enable in production for security
- Passwords hashed and secured by Firebase

---

### 1.3 Cloud Firestore

**Package**: `cloud_firestore: ^4.17.0`

**Database Structure**:

#### Collections

##### 1. **`inventory`** Collection
```javascript
inventory/{itemId}
{
  sapCode: string,          // Unique SAP identifier
  name: string,             // Item name
  internalRef: string,      // Internal reference code
  description: string,      // Item description
  currentStock: number,     // Current quantity
  maxStock: number,         // Safety stock level
  replenishQty: number,     // Replenishment quantity
  rackNumber: string,       // Rack location
  rackLevel: string,        // Rack level
  location: string,         // Full location
  lastUpdated: timestamp,   // Last modification
  recentActivity: array     // Activity log
}
```

**Indexes**:
- `sapCode` (ascending)
- `name` (ascending)
- `lastUpdated` (descending)

##### 2. **`users`** Collection
```javascript
users/{userId}
{
  uid: string,              // Firebase Auth UID
  email: string,            // User email
  displayName: string,      // User full name
  userGroup: string,        // Role: A/S/T
  isActive: boolean,        // Account status
  createdAt: timestamp,     // Registration date
  lastLogin: timestamp,     // Last login time
  updatedAt: timestamp      // Last profile update
}
```

##### 3. **`receivings`** Collection
```javascript
receivings/{receiptId}
{
  sapCode: string,
  itemName: string,
  quantityReceived: number,
  supplier: string,
  remarks: string,
  timestamp: timestamp,
  date: string,             // ISO format
  status: string,           // "completed"
  userId: string            // Who received
}
```

##### 4. **`issuance`** Collection
```javascript
issuance/{issuanceId}
{
  sapCode: string,
  itemName: string,
  quantityIssued: number,
  usageLocation: string,
  technicianName: string,
  remarks: string,
  timestamp: timestamp,
  date: string,
  status: string,
  userId: string            // Who issued
}
```

##### 5. **`movement_logs`** Collection
```javascript
movement_logs/{logId}
{
  type: string,             // "Inbound" | "Outbound"
  sapCode: string,
  itemName: string,
  quantity: number,
  source: string,           // Supplier or location
  remarks: string,
  timestamp: timestamp,
  date: string,
  status: string,
  movementType: string,     // "receiving" | "issuance"
  userId: string
}
```

**Firestore Operations**:
```dart
// Read operations
FirebaseFirestore.instance.collection('inventory').snapshots()
FirebaseFirestore.instance.collection('inventory').doc(id).get()

// Write operations
FirebaseFirestore.instance.collection('inventory').add(data)
FirebaseFirestore.instance.collection('inventory').doc(id).update(data)
FirebaseFirestore.instance.collection('inventory').doc(id).delete()

// Real-time listeners
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
  builder: (context, snapshot) { ... }
)
```

**Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Require authentication
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // User-specific rules
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId 
                   || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userGroup == 'A';
    }
    
    // Inventory rules
    match /inventory/{itemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null 
                    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userGroup == 'A';
    }
  }
}
```

---

### 1.4 Firebase Storage

**Package**: `firebase_storage: ^11.6.0`

**Usage**: Prepared for future image upload features
- Item images
- User profile pictures
- Document attachments

**Storage Structure**:
```
storage/
├── items/
│   └── {itemId}/
│       └── images/
├── users/
│   └── {userId}/
│       └── profile.jpg
└── documents/
    └── {docId}/
```

**Not fully implemented yet** - infrastructure ready

---

### 1.5 Firebase App Check

**Package**: `firebase_app_check: ^0.2.0`

**Purpose**: Protect backend resources from abuse

**Configuration**:
```dart
// Disabled for development on free tier
// Enable for production with Blaze plan
```

**Production Setup**:
1. Register app with App Check
2. Configure reCAPTCHA v3 or SafetyNet
3. Update security rules to require App Check token

---

## 2. Flutter Packages

### 2.1 Core Dependencies

#### **Provider** - State Management
```yaml
provider: ^6.0.5
```

**Usage**:
```dart
// Providing AuthService
Provider<AuthService>(
  create: (_) => authService,
  child: const MyApp(),
)

// Consuming
final authService = Provider.of<AuthService>(context);
```

#### **RxDart** - Reactive Programming
```yaml
rxdart: ^0.27.0
```

**Usage**: Combining multiple Firestore streams
```dart
// usage_history_screen.dart
Stream<List<Transaction>> combinedStream = Rx.combineLatest2(
  FirebaseFirestore.instance.collection('receivings').snapshots(),
  FirebaseFirestore.instance.collection('issuance').snapshots(),
  (QuerySnapshot receivings, QuerySnapshot issuance) {
    // Combine both streams
  }
);
```

---

### 2.2 UI & Media Packages

#### **Image Picker**
```yaml
image_picker: ^1.0.0
image: ^4.1.0
```

**Purpose**: Select images from gallery/camera (future feature)

#### **Path Provider**
```yaml
path_provider: ^2.1.0
```

**Purpose**: Access device directories for file storage

---

### 2.3 Document Generation

#### **PDF & Printing**
```yaml
pdf: ^3.10.0
printing: ^5.10.0
```

**Purpose**: Generate and print reports (prepared for future)

#### **Excel Export**
```yaml
excel: ^4.0.0
```

**Purpose**: Export inventory data to Excel (future feature)

---

### 2.4 Utilities

#### **Internationalization**
```yaml
intl: ^0.19.0
```

**Usage**: Date formatting
```dart
import 'package:intl/intl.dart';

DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())
```

#### **HTTP Client**
```yaml
http: ^1.2.0
```

**Purpose**: API calls (if needed for external services)

#### **Google Sign-In**
```yaml
google_sign_in: ^6.3.0
```

**Status**: Package added but not implemented yet

---

### 2.5 Development Dependencies

#### **Flutter Lints**
```yaml
flutter_lints: ^2.0.0
```

**Purpose**: Code quality and style enforcement

#### **Launcher Icons**
```yaml
flutter_launcher_icons: ^0.14.4
```

**Configuration**:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/company_logo_1.jpeg"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/company_logo_1.jpeg"
```

---

## 3. Service Architecture

### 3.1 Service Layer Design

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│         (UI Screens/Widgets)        │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│         Service Layer               │
│  ┌─────────────────────────────┐   │
│  │ AuthService                 │   │
│  │ - Authentication logic      │   │
│  │ - User profile management   │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ InventoryService            │   │
│  │ - CRUD operations           │   │
│  │ - Stock management          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ActivityLoggingService      │   │
│  │ - Activity tracking         │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ValidationService           │   │
│  │ - Input validation          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ FirebaseService             │   │
│  │ - Firebase initialization   │   │
│  └─────────────────────────────┘   │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│        Firebase Backend             │
│  ┌─────────────────────────────┐   │
│  │ Firebase Auth               │   │
│  │ Cloud Firestore             │   │
│  │ Firebase Storage            │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 3.2 Service Implementations

#### **AuthService** (`lib/services/auth_service.dart`)
- User authentication
- Session management
- Profile operations
- Role management

#### **InventoryService** (`lib/services/inventory_service.dart`)
- Inventory CRUD operations
- Stock calculations
- Item queries

#### **ActivityLoggingService** (`lib/services/activity_logging_service.dart`)
- Activity tracking
- Audit trail
- User action logging

#### **ValidationService** (`lib/services/validation_service.dart`)
- Form validation
- Data sanitization
- Business rule validation

#### **FirebaseService** (`lib/services/firebase_service.dart`)
- Firebase initialization
- Configuration management

---

## 4. API Integration

### 4.1 Firebase REST API

Firebase provides REST APIs for external access (not used in app but available):

**Authentication API**:
```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
```

**Firestore REST API**:
```
GET https://firestore.googleapis.com/v1/projects/{project}/databases/(default)/documents/inventory
```

### 4.2 Internal APIs

All APIs are internal Flutter method calls through Firebase SDKs.

---

## 5. Configuration Files

### 5.1 Firebase Configuration

#### **google-services.json**
- **Location**: `android/app/google-services.json`
- **Purpose**: Android Firebase configuration
- **Generated by**: Firebase Console / FlutterFire CLI
- **Contents**: 
  - Project ID
  - API keys
  - OAuth client IDs
  - Database URLs

**Generation Command**:
```bash
flutterfire configure --platforms=android --project <project-id>
```

---

### 5.2 Android Configuration

#### **build.gradle.kts** (Project Level)
- **Location**: `android/build.gradle.kts`
- **Key Dependencies**:
  ```kotlin
  classpath("com.google.gms:google-services:4.4.0")
  ```

#### **build.gradle.kts** (App Level)
- **Location**: `android/app/build.gradle.kts`
- **Configuration**:
  ```kotlin
  android {
      compileSdk = 34
      minSdk = 21
      targetSdk = 34
  }
  
  plugins {
      id("com.google.gms.google-services")
  }
  ```

---

### 5.3 Flutter Configuration

#### **pubspec.yaml**
- **Location**: `engineering_store/pubspec.yaml`
- **Contains**:
  - App metadata
  - Dependencies
  - Assets configuration
  - Flutter settings

---

## 6. Security Implementation

### 6.1 Network Security

**HTTPS Only**:
- All Firebase communication over HTTPS
- Secure WebSocket connections for real-time data

**Certificate Pinning**:
- Handled by Firebase SDK
- No additional configuration needed

---

### 6.2 Data Security

**Encryption**:
- Data encrypted in transit (TLS 1.2+)
- Data encrypted at rest (Firebase default)

**Authentication**:
- Firebase Auth tokens
- Secure session management
- Token refresh automatic

**Authorization**:
- Firestore security rules
- Role-based access control
- Field-level security

---

### 6.3 Input Validation

**Client-Side**:
- Form validation
- Data type checking
- Length validation
- Format validation

**Server-Side**:
- Firestore security rules validate writes
- Type enforcement in database

---

## 7. Data Flow

### 7.1 Read Operations

```
User Action → Screen → Service → Firestore → StreamBuilder → UI Update
```

**Example**: Load inventory list
```dart
// inventory_list_screen.dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
  builder: (context, snapshot) {
    // UI automatically updates when data changes
  }
)
```

---

### 7.2 Write Operations

```
User Input → Validation → Service → Firestore → Success/Error → UI Feedback
```

**Example**: Add inventory item
```dart
// add_item_screen.dart
await FirebaseFirestore.instance.collection('inventory').add({
  'sapCode': sapCode,
  'name': itemName,
  // ... other fields
  'lastUpdated': FieldValue.serverTimestamp(),
});
```

---

### 7.3 Transaction Flow

**Receive Item**:
```
1. User selects item and enters quantity
2. Validate stock availability
3. Save to 'receivings' collection
4. Save to 'movement_logs' collection
5. Update inventory stock (+quantity)
6. Show success message
7. UI updates automatically via StreamBuilder
```

**Issue Item**:
```
1. User selects item and enters quantity
2. Validate stock availability (prevent over-issuing)
3. Save to 'issuance' collection
4. Save to 'movement_logs' collection
5. Update inventory stock (-quantity)
6. Show success message
7. UI updates automatically via StreamBuilder
```

---

## 8. Integration Checklist

### ✅ Completed Integrations
- [x] Firebase Core
- [x] Firebase Authentication
- [x] Cloud Firestore
- [x] Firebase Storage (infrastructure)
- [x] Provider state management
- [x] RxDart stream combining
- [x] Intl date formatting
- [x] Flutter linting
- [x] App icon generation

### ⏸️ Partial Integrations
- [ ] Firebase Analytics (not implemented)
- [ ] Firebase Cloud Messaging (not implemented)
- [ ] Google Sign-In (package added, not implemented)
- [ ] PDF generation (package added, not implemented)
- [ ] Excel export (package added, not implemented)

### ❌ Not Integrated
- [ ] Crashlytics
- [ ] Remote Config
- [ ] A/B Testing
- [ ] Performance Monitoring

---

## 9. Environment Configuration

### 9.1 Development Environment
```
Flutter: 3.35.6 (stable)
Dart: 3.5.4
Android SDK: 34
Build Tools: Latest
Gradle: 8.x
Kotlin: 1.9.x
```

### 9.2 Firebase Environment
```
Plan: Spark (Free Tier)
Region: US
Firestore Mode: Native
Storage: Default bucket
```

### 9.3 API Keys
- Stored in `google-services.json`
- Not committed to version control (add to .gitignore)
- Regenerate for production

---

## 10. Troubleshooting Integration Issues

### Firebase Connection Issues
```bash
# Verify google-services.json is in correct location
ls android/app/google-services.json

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Firestore Permission Denied
- Check security rules in Firebase Console
- Verify user is authenticated
- Check user has correct role

### Real-time Updates Not Working
- Verify StreamBuilder implementation
- Check Firestore connection status
- Ensure proper error handling

---

## Conclusion

All core integrations are complete and functional. The application successfully integrates with Firebase services for authentication, database, and storage. Additional packages are prepared for future enhancements.

---

**Document Version**: 1.0  
**Last Updated**: February 4, 2026  
**Maintained by**: DevX Development Team
