# Engineering Store - Inventory Management Application

A Flutter mobile application for managing engineering store inventory with Firebase backend support. Built for Android devices, featuring real-time inventory tracking, user authentication, and transaction recording.

## 🎯 Features

- **User Authentication** - Email/password login with Firebase Auth
- **Dashboard Overview** - Real-time statistics showing total items, low stock, and out-of-stock counts
- **Inventory Management** - Add, edit, view, search, and delete inventory items in real-time
- **Receive Items** - Record supplier deliveries with automatic stock updates
- **Issue Items** - Record item issuance to technicians with stock validation
- **Usage History** - View combined transaction history (receiving and issuance)
- **Movement Tracking** - Complete audit trail of all inventory movements
- **Quick Actions** - Fast access to receive and issue items from home screen
- **Real-time Firestore Sync** - Automatic data synchronization with Firebase Firestore
- **Delete Functionality** - Single or mass delete items with confirmation dialogs

## 🛠️ Prerequisites

- **Flutter SDK** - Version 3.35.6 or higher
  - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** - With Android SDK and AVD emulator
- **Firebase Project** - Created at [Firebase Console](https://console.firebase.google.com/)
- **Git** - For version control

## 📋 Project Structure

```
lib/
├── main.dart                           # App entry point, Firebase initialization
├── screens/
│   ├── login_screen.dart              # User login interface
│   ├── home_screen.dart               # Main dashboard with real-time stats
│   ├── inventory_list_screen.dart     # Real-time inventory list with delete
│   ├── add_item_screen.dart           # Form to add new inventory items
│   ├── edit_item_screen.dart          # Edit existing inventory items
│   ├── inventory_detail_screen.dart   # Detailed view with edit/adjust buttons
│   ├── receive_item_screen.dart       # Record supplier deliveries
│   ├── issue_item_screen.dart         # Record item issuance to technicians
│   ├── usage_history_screen.dart      # Combined receiving and issuance history
│   ├── movement_logs_screen.dart      # Complete inventory movement audit trail
│   ├── record_usage_screen.dart       # Hub for receiving/issuing items
│   ├── master_data_screen.dart        # Master data management options
│   └── forgot_password_screen.dart    # Password recovery
└── services/
    ├── auth_service.dart              # Firebase authentication methods
    ├── firebase_service.dart          # Firestore operations
    └── inventory_service.dart         # Inventory management logic

assets/                                # Application assets and images
```

## 🚀 Quick Start

### 1. Clone & Setup Dependencies

```powershell
cd "c:\Mobile Apps Development\MAP-DevX\engineering_store"
flutter pub get
```

### 2. Configure Firebase (One-time)

```powershell
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase for Android
flutterfire configure --platforms=android --project <YOUR_FIREBASE_PROJECT_ID>
```

This command generates:
- `lib/firebase_options.dart` - Firebase configuration
- `android/app/google-services.json` - Android Firebase setup

### 3. Launch Emulator

```powershell
# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch Pixel_5_API_34
```

### 4. Run the App

```powershell
flutter run
```

## 🔐 Authentication Flow

### Login
1. User enters email and password
2. Firebase Authentication verifies credentials
3. User role and approval status checked
4. Redirects to home screen on success

### Initial Setup
- Default admin account can be created through the app
- New users register with email, password, and role selection
- Admin approval required before full access (for non-admin users)

## 📱 Main Screens

### Home Screen
Central dashboard showing:
- **Dashboard Overview** - Real-time counts of total items, low stock (1-5 units), and out-of-stock items
  - Click on "Total Items" to navigate to inventory list
- **Quick Actions** - Fast access buttons:
  - Receive Item - Go to receive items screen
  - Issue Items - Go to issue items screen
- **Main Menu** with three sections:
  - **Inventory Holding** - View/manage inventory items
  - **Inventory Consumption** - Record usage, view history
  - **System Management** - Movement logs and master data

### Inventory List
- Real-time synchronization with Firestore
- Search and filter capabilities
- Single-item delete via long-press
- Mass delete with checkboxes and confirmation
- View item details (SAP code, quantity, location, etc.)
- Add or edit items

### Receive Item Screen
- Record supplier deliveries
- Fields: SAP Number, Item Name, Quantity Received, Supplier, Remarks
- Auto-timestamp on save
- Updates both `receivings` and `movement_logs` collections
- Automatically increases inventory stock

### Issue Item Screen
- Record item issuance to technicians
- Fields: SAP Number, Item Name, Quantity Needed, Usage Location, Technician Name
- Stock validation before issuance
- Auto-timestamp on save
- Updates both `issuance` and `movement_logs` collections
- Automatically decreases inventory stock

### Usage History Screen
- View combined receiving and issuance transactions
- Real-time data from both `receivings` and `issuance` collections
- Filter by transaction type (All, Receiving, Issuance)
- Chronologically sorted by transaction timestamp

### Movement Logs Screen
- Complete audit trail of all inventory movements
- Shows Inbound (from receiving) and Outbound (from issuance) movements
- Filter by movement type
- Timestamp and user information for each movement

### Inventory Detail Screen
- Comprehensive item information display
- Stock status indicator (OUT OF STOCK, LOW STOCK, IN STOCK)
- Action buttons:
  - Edit Item - Navigate to edit screen
  - Adjust Stock - Open stock adjustment dialog
- Recent activity log

### Add/Edit Item
- SAP Number (required)
- Item Name (required)
- Internal Reference
- Description
- Safety Stock Level
- Replenishment Quantity
- Current Quantity
- Rack Location Details

## 🗄️ Firebase Setup

### Required Firestore Collections

**`inventory`** - Stores all inventory items
```
sapCode: string
name: string
internalRef: string
description: string
maxStock: number (safety stock level)
replenishQty: number
currentStock: number
rackNumber: string
rackLevel: string
location: string
lastUpdated: timestamp
recentActivity: array
```

**`receivings`** - Supplier delivery records
```
sapCode: string
itemName: string
quantityReceived: number
supplier: string
remarks: string
timestamp: timestamp
date: string
status: string
```

**`issuance`** - Item issuance records
```
sapCode: string
itemName: string
quantityIssued: number
usageLocation: string
technicianName: string
remarks: string
timestamp: timestamp
date: string
status: string
```

**`movement_logs`** - Audit trail of all movements
```
type: string (Inbound, Outbound)
sapCode: string
itemName: string
quantity: number
source: string
remarks: string
timestamp: timestamp
date: string
status: string
movementType: string
```

**`users`** - Stores user profile data
```
uid: string
email: string
name: string
role: string
approved: boolean
passwordVerified: boolean
isAdmin: boolean
```

### Firestore Security Rules

Ensure your Firestore security rules allow:
- Authenticated users to read/write their own data
- Admins to manage all collections
- Real-time synchronization for all collections

Example (development):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /inventory/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid != null;
    }
    match /receivings/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /issuance/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /movement_logs/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /users/{userId} {
      allow read: if request.auth.uid == userId || request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## 🔧 Development & Building

### Clean Build
```powershell
flutter clean
flutter pub get
flutter run
```

### Build APK (Release)
```powershell
flutter build apk --release
```

### View Logs
```powershell
flutter logs
```

## 📦 Dependencies

- **firebase_core** ^2.24.0 - Firebase initialization
- **firebase_auth** ^4.16.0 - Authentication
- **cloud_firestore** ^4.17.0 - Real-time database
- **firebase_storage** ^11.6.0 - File storage
- **google_sign_in** ^6.3.0 - Google authentication
- **rxdart** ^0.27.0 - Stream utilities for combining streams
- **intl** ^0.19.0 - Internationalization

## ⚠️ Important Notes

### Data Synchronization
- **Inventory List** uses Firestore `StreamBuilder` for real-time updates
- **Usage History** combines data from `receivings` and `issuance` collections using `Rx.combineLatest2`
- **Movement Logs** shows all movements from `movement_logs` collection
- Requires active Firebase connection for real-time sync

### Transaction Recording
- When you receive an item, it updates: `receivings`, `movement_logs`, and `inventory` collections
- When you issue an item, it updates: `issuance`, `movement_logs`, and `inventory` collections
- Stock is automatically adjusted on both operations

### Android Emulator
- reCAPTCHA is disabled for development testing on emulator
- Use release builds for production deployment

### Firestore Collections
- Collections are created automatically on first write operation
- Ensure proper security rules are set for all collections

## 🧪 Testing the App

### Test User Registration
1. Click "Create Account" on login screen
2. Fill in email, password, and name
3. Select user role
4. Complete registration

### Test Inventory Management
1. Login with valid credentials
2. Navigate to "Inventory Items"
3. Click + button to add new item
4. Fill in all required fields
5. Item appears instantly in the list
6. Long-press to delete single item or use checkboxes for mass delete

### Test Transaction Recording
1. Go to "Quick Actions" or "Record Usage"
2. Click "Receive Item" to record supplier delivery
3. Fill in item details and quantity received
4. Item stock automatically increases
5. Transaction appears in Usage History and Movement Logs

### Test Issuance Recording
1. Go to "Quick Actions" or "Record Usage"
2. Click "Issue Item" to record technician issuance
3. Fill in item details and quantity needed
4. System validates available stock
5. Item stock automatically decreases
6. Transaction appears in Usage History and Movement Logs

### Test Dashboard Overview
1. Check home screen shows real-time counts
2. Items with 0 stock count in "Out of Stock"
3. Items with 1-5 stock count in "Low Stock"
4. Click "Total Items" to navigate to inventory list

## 🐛 Troubleshooting

### App won't run
```powershell
flutter clean
flutter pub get
flutter run
```

### Firebase connection issues
- Verify Firebase project ID in `android/app/google-services.json`
- Check Firestore security rules allow your user access
- Ensure internet connection on emulator

### Items not appearing in inventory list
- Check Firestore has `inventory` collection with documents
- Verify Firestore security rules allow read access
- Check Flutter console logs for errors (run with `flutter logs`)

### Transactions not appearing in usage history
- Verify `receivings` and `issuance` collections have documents
- Check that timestamp field is saved correctly (should be Firestore Timestamp type)
- Verify rxdart dependency is included in pubspec.yaml
- Check Firestore security rules allow read access to both collections

### Version conflicts
- Review `pubspec.yaml` for Firebase package versions
- Run `flutter pub upgrade` to update compatible versions

## 📝 Version Info

- **Flutter Version**: 3.35.6 (stable)
- **Target Android**: API 34
- **Dart**: 3.5.4

## 📄 Additional Documentation

- [SETUP_COMPLETE.md](Project%20Document/SETUP_COMPLETE.md) - Project completion status
- [DOCUMENTATION_INDEX.md](Project%20Document/DOCUMENTATION_INDEX.md) - Complete documentation index
- [COMPLETION_REPORT.md](Project%20Document/COMPLETION_REPORT.md) - Project completion report
- [IMPLEMENTATION_CHECKLIST.md](Project%20Document/IMPLEMENTATION_CHECKLIST.md) - Feature implementation tracking
- [INTEGRATION_SUMMARY.md](Project%20Document/INTEGRATION_SUMMARY.md) - Firebase integration details
- [QUICK_REFERENCE.md](Project%20Document/QUICK_REFERENCE.md) - Quick command and API reference
- [SOFTWARE_REQUIREMENT_SPECIFICATION.md](Project%20Document/SOFTWARE_REQUIREMENT_SPECIFICATION.md) - Complete SRS document
- [TESTING_GUIDE.md](Project%20Document/TESTING_GUIDE.md) - Comprehensive testing procedures

## 🤝 Contributing

When making changes:
1. Update relevant screens in `/lib/screens`
2. Update services in `/lib/services` if backend logic changes
3. Test on Android emulator before committing
4. Update this README if adding new features

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Flutter and Firebase logs
3. Consult the official documentation links

#### Maintain by DevX Development Team

