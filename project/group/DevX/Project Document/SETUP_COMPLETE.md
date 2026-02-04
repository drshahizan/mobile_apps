# Engineering Store - Inventory Management System ✅

## Project Completion Status

The Engineering Store Flutter application has been successfully developed with full inventory management capabilities, real-time Firestore synchronization, user authentication, and transaction recording features.

---

## ✨ Implemented Features

### 🔐 **Authentication System**
- Email/password authentication via Firebase Auth
- Role-based access control (Technician, Storekeeper, Manager, Auditor, Admin)
- User registration with approval workflow
- Admin account creation for testing
- Secure login with session management

### 📊 **Dashboard & Overview**
- Real-time dashboard statistics:
  - **Total Items** - Count of all inventory items (clickable to navigate to inventory list)
  - **Low Stock** - Count of items with 1-5 units remaining
  - **Out of Stock** - Count of items with 0 units
- Quick Access buttons:
  - **Receive Item** - Direct navigation to receiving form
  - **Issue Item** - Direct navigation to issuance form
- Dynamic stats updated in real-time from Firestore

### 📦 **Inventory Management**
- Real-time inventory list with Firestore StreamBuilder
- Add new items with comprehensive form validation
- Edit existing inventory items
- Delete items (single via long-press, multiple via checkboxes)
- Search and filter inventory by SAP code, name, or description
- View detailed item information (stock levels, rack location, safety stock, etc.)
- Real-time stock synchronization across all screens
- Action buttons on detail screen (Edit Item, Adjust Stock)

### 🚚 **Transaction Recording**

#### **Receive Item Screen**
- Record supplier deliveries
- Fields: SAP Number, Item Name, Quantity Received, Supplier, Remarks
- Auto-timestamp on submission
- Saves to both `receivings` and `movement_logs` collections
- Automatically increases inventory stock

#### **Issue Item Screen**
- Record item issuance to technicians
- Fields: SAP Number, Item Name, Quantity Needed, Usage Location, Technician Name
- Stock validation before issuance (prevents over-issuing)
- Auto-timestamp on submission
- Saves to both `issuance` and `movement_logs` collections
- Automatically decreases inventory stock

### 📊 **History & Tracking**

#### **Usage History Screen**
- View combined receiving and issuance transactions
- Real-time data from both `receivings` and `issuance` collections
- Filter options: All, Receiving, Issuance
- Chronologically sorted by transaction timestamp
- Shows item details, quantity, user, and date/time

#### **Movement Logs Screen**
- Complete audit trail of all inventory movements
- Shows all movements with type (Inbound/Outbound)
- Filter by movement type
- Displays timestamp, user, quantity, and item details
- Comprehensive tracking for inventory compliance

### 🔄 **Stock Management**
- Current stock quantity tracking
- Safety stock level configuration
- Replenishment quantity management
- Stock status indicators (OUT, LOW!, GOOD)
- Real-time stock updates on receive/issue operations
- Dashboard overview of stock health

### 📁 **System Management**
- Master data management options
- Movement logs for audit trail
- User management capabilities

---

## 📁 Project Structure

```
lib/
├── main.dart                           # App initialization and Firebase setup
├── screens/
│   ├── login_screen.dart              # User authentication
│   ├── home_screen.dart               # Main dashboard with real-time stats
│   ├── inventory_list_screen.dart     # Firestore-backed inventory list with delete
│   ├── add_item_screen.dart           # Add new items form
│   ├── edit_item_screen.dart          # Edit existing items
│   ├── inventory_detail_screen.dart   # Item details with action buttons
│   ├── receive_item_screen.dart       # Record supplier deliveries
│   ├── issue_item_screen.dart         # Record item issuance
│   ├── usage_history_screen.dart      # Combined transaction history
│   ├── movement_logs_screen.dart      # Inventory movement audit trail
│   ├── record_usage_screen.dart       # Usage recording hub
│   ├── master_data_screen.dart        # Master data options
│   └── forgot_password_screen.dart    # Password recovery
├── services/
│   ├── auth_service.dart              # Authentication logic
│   ├── firebase_service.dart          # Firestore operations
│   └── inventory_service.dart         # Inventory management
└── assets/                            # Images and resources

android/
├── app/
│   └── google-services.json           # Firebase configuration
└── gradle configurations              # Android build setup
```

---

## 🗄️ Firebase Setup

### **Firestore Collections**

**`inventory`** - Stores all inventory items
```
Document fields:
├── sapCode: string          # SAP item number
├── name: string             # Item name
├── internalRef: string      # Internal reference
├── description: string      # Item description
├── currentStock: number     # Current quantity
├── maxStock: number         # Safety stock level
├── replenishQty: number     # Replenishment quantity
├── rackNumber: string       # Rack location
├── rackLevel: string        # Shelf/level position
├── location: string         # Full location description
├── lastUpdated: timestamp   # Last modification time
└── recentActivity: array    # Activity log
```

**`receivings`** - Supplier delivery records
```
Document fields:
├── sapCode: string          # SAP item number
├── itemName: string         # Item name
├── quantityReceived: number # Quantity received
├── supplier: string         # Supplier name
├── remarks: string          # Additional remarks
├── timestamp: timestamp     # Server timestamp
├── date: string            # ISO date format
└── status: string          # Completion status
```

**`issuance`** - Item issuance records
```
Document fields:
├── sapCode: string          # SAP item number
├── itemName: string         # Item name
├── quantityIssued: number   # Quantity issued
├── usageLocation: string    # Location where item is used
├── technicianName: string   # Technician receiving item
├── remarks: string          # Additional remarks
├── timestamp: timestamp     # Server timestamp
├── date: string            # ISO date format
└── status: string          # Completion status
```

**`movement_logs`** - Audit trail of all movements
```
Document fields:
├── type: string             # Movement type (Inbound/Outbound)
├── sapCode: string          # SAP item number
├── itemName: string         # Item name
├── quantity: number         # Quantity moved
├── source: string           # Source/destination
├── remarks: string          # Additional remarks
├── timestamp: timestamp     # Server timestamp
├── date: string            # ISO date format
├── status: string          # Completion status
└── movementType: string    # Type classification (receiving/issuance)
```

**`users`** - User profile and authentication data
```
Document fields:
├── uid: string              # Firebase UID
├── email: string            # User email
├── name: string             # User name
├── role: string             # User role
├── approved: boolean        # Admin approval status
├── isAdmin: boolean         # Admin flag
└── createdAt: timestamp     # Registration date
```

### **Security Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /inventory/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
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
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🚀 How to Run

### 1. **Setup Dependencies**
```powershell
cd "c:\Mobile Apps Development\MAP-DevX\engineering_store"
flutter pub get
```

### 2. **Configure Firebase** (if not done)
```powershell
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android --project <YOUR_PROJECT_ID>
```

### 3. **Launch Emulator**
```powershell
flutter emulators --launch Pixel_5_API_34
```

### 4. **Run Application**
```powershell
flutter run
```

### 5. **Clean Build** (if experiencing issues)
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Testing Scenarios

### **Test Dashboard Overview**
1. Login with valid credentials
2. Home screen displays real-time counts:
   - Total Items count updates when items are added/deleted
   - Low Stock shows items with 1-5 units
   - Out of Stock shows items with 0 units
3. Click on "Total Items" card to navigate to inventory list
4. Quick Action buttons are accessible

### **Test Quick Actions**
1. Click "Receive Item" button from home screen
2. Navigate to receive items form
3. Click "Issue Item" button from home screen
4. Navigate to issue items form

### **Test Receive Item Workflow**
1. Go to Quick Actions → Receive Item
2. Select SAP number from dropdown
3. Item name auto-fills
4. Enter Quantity Received
5. Enter Supplier name
6. Submit form
7. Item stock increases in inventory
8. Transaction appears in Usage History (Receiving filter)
9. Movement appears in Movement Logs (Inbound filter)

### **Test Issue Item Workflow**
1. Go to Quick Actions → Issue Item
2. Select SAP number with available stock
3. Item name auto-fills
4. Enter Quantity Needed (validates against available stock)
5. Enter Usage Location
6. Enter Technician Name
7. Submit form
8. Item stock decreases in inventory
9. Transaction appears in Usage History (Issuance filter)
10. Movement appears in Movement Logs (Outbound filter)

### **Test Usage History**
1. Navigate to "Record Usage" → "Usage History"
2. View all transactions (receiving and issuance combined)
3. Filter by "Receiving" to see only received items
4. Filter by "Issuance" to see only issued items
5. Verify transactions are sorted chronologically (newest first)
6. Check timestamps match when items were received/issued

### **Test Movement Logs**
1. Navigate to "System Management" → "Movement Logs"
2. View all inventory movements
3. Filter by "Inbound" to see receiving transactions
4. Filter by "Outbound" to see issuance transactions
5. Verify complete audit trail

### **Test Inventory Management**
1. Navigate to "Inventory Items"
2. Add new item via + button
3. Item appears instantly in list
4. Search/filter for the item
5. Long-press item to delete single item
6. Use checkboxes for mass delete with confirmation

### **Test Item Details**
1. Click on an item to view details
2. Click "Edit Item" button to navigate to edit screen
3. Click "Adjust Stock" button to open adjustment dialog
4. Verify stock status (OUT, LOW!, GOOD) updates correctly

### **Test Real-time Synchronization**
1. Open app on emulator
2. Receive an item (stock increases)
3. Immediately check Inventory List
4. Stock reflects new value instantly
5. Check Usage History and Movement Logs
6. New transactions appear without refreshing

---

## 📦 Dependencies

### **Firebase Stack**
- firebase_core: ^2.24.0
- firebase_auth: ^4.16.0
- cloud_firestore: ^4.17.0
- firebase_storage: ^11.6.0

### **Stream & Reactive**
- rxdart: ^0.27.0 (for combining multiple Firestore streams)

### **UI & Utilities**
- google_sign_in: ^6.3.0
- intl: ^0.19.0

---

## 🔑 Key Technical Decisions

### **Real-time Data Synchronization**
- **Inventory List** uses `StreamBuilder<QuerySnapshot>` for real-time Firestore updates
- **Usage History** combines `receivings` and `issuance` streams using `Rx.combineLatest2`
- **Movement Logs** streams all movements in real-time
- Automatically rebuilds UI when data changes
- Eliminates need for manual refresh buttons

### **Data Architecture**
- Firestore as single source of truth for all data
- Transactions saved to multiple collections for audit trail:
  - Receive: saved to `receivings` and `movement_logs`
  - Issue: saved to `issuance` and `movement_logs`
- Stock automatically updated on both operations
- No in-memory caching (always fresh from Firestore)

### **User Experience**
- Smooth navigation between screens
- Real-time stock status indicators
- Color-coded status badges (Red=OUT, Orange=LOW, Green=GOOD)
- Instant feedback on all operations
- Transaction history visible immediately
- Quick actions for common tasks

---

## ⚠️ Important Notes

### **Firestore Collection Requirements**
- All collections created automatically on first write
- Proper security rules required for read/write access
- Each transaction creates documents in multiple collections for audit trail

### **Real-time Sync Behavior**
- When you receive an item, stock increases **instantly**
- When you issue an item, stock decreases **instantly**
- Transactions appear in Usage History without page refresh
- Requires active internet connection to Firestore

### **Stock Validation**
- Issue Item screen validates available stock before submission
- Prevents issuance of more items than available
- Provides clear error messages to users

### **Android Emulator**
- reCAPTCHA disabled for development/testing
- Use release builds for production with full security enabled

### **Firebase Configuration**
- `google-services.json` required in `android/app/`
- Generated by `flutterfire configure` command
- Contains project-specific credentials

---

## 🐛 Troubleshooting

### **Items Not Appearing in List**
1. Check Firestore console for `inventory` collection
2. Verify security rules allow read access
3. Check app logs: `flutter logs`
4. Ensure Firebase connection is active

### **Transactions Not Appearing in Usage History**
1. Verify `receivings` and `issuance` collections have documents
2. Check timestamp field format (should be Firestore Timestamp)
3. Verify rxdart package is in pubspec.yaml
4. Check Firestore security rules allow read access
5. Review Flutter logs for stream errors

### **Stock Not Updating**
1. Verify transaction saved to Firestore
2. Check inventory document has `currentStock` field
3. Ensure Firestore security rules allow write access
4. Check if stock reached boundaries (out of stock, low stock)

### **Build Failures**
```powershell
flutter clean
flutter pub get
flutter run
```

### **Firebase Connection Issues**
- Verify Firebase project ID in `google-services.json`
- Check Android device/emulator internet connection
- Review Firestore security rules
- Check emulator has correct API level (34+)

---

## 📊 Current Status

| Feature | Status | Notes |
|---------|--------|-------|
| Authentication | ✅ Complete | Email/password login working |
| Home Dashboard | ✅ Complete | Real-time stat cards with click navigation |
| Inventory List | ✅ Complete | Real-time Firestore sync, search, delete |
| Add Items | ✅ Complete | Form validation implemented |
| Edit Items | ✅ Complete | Edit functionality ready |
| Receive Items | ✅ Complete | Supplier delivery recording working |
| Issue Items | ✅ Complete | Technician issuance with stock validation |
| Usage History | ✅ Complete | Combined receive/issuance transactions |
| Movement Logs | ✅ Complete | Audit trail visible |
| Quick Actions | ✅ Complete | Fast access from home screen |
| Item Details | ✅ Complete | Edit and adjust stock buttons |
| Stock Management | ✅ Complete | Real-time updates on transactions |
| Search/Filter | ✅ Complete | Real-time filtering works |
| Master Data | ✅ Complete | Admin options accessible |
| UI/UX | ✅ Complete | Material Design 3 implemented |
| Firebase Integration | ✅ Complete | Full Firestore sync active |

---

## 🔄 Development Notes

### **Code Quality**
- All screens use proper state management
- StreamBuilder for real-time data (no polling)
- Rx.combineLatest2 for multi-stream combinations
- Proper error handling and user feedback
- Clean separation of concerns (screens, services, models)

### **Performance Optimizations**
- Efficient Firestore queries
- No unnecessary rebuilds
- Real-time sync vs. periodic polling
- Proper disposal of resources
- Stream-based state management

### **Security Considerations**
- Firebase Auth for user verification
- Firestore security rules for data access
- No sensitive data in app code
- reCAPTCHA disabled only in development
- Stock validation before issuance

---

## 📝 Version Information

- **Flutter Version**: 3.35.6 (stable)
- **Dart Version**: 3.5.4
- **Target Platform**: Android API 34
- **Min SDK**: Android 21+
- **Build Date**: January 4, 2026

---

## 📚 Documentation References

- [README.md](README.md) - Detailed setup and feature guide
- [Firebase Flutter Guide](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [RxDart Documentation](https://pub.dev/packages/rxdart)

---

## ✅ Completion Checklist

- ✅ User authentication system
- ✅ Real-time dashboard overview with click navigation
- ✅ Real-time inventory synchronization
- ✅ Add/Edit/View/Delete items
- ✅ Quick action buttons for receive/issue
- ✅ Receive item transaction recording
- ✅ Issue item transaction recording with stock validation
- ✅ Usage history combining both transaction types
- ✅ Complete movement audit trail
- ✅ Search and filter functionality
- ✅ Stock status indicators
- ✅ Master data management
- ✅ Admin controls
- ✅ Responsive UI design
- ✅ Error handling and validation
- ✅ Real-time stream synchronization
- ✅ Multi-collection transaction support
- ✅ Firebase integration
- ✅ Production-ready code

---

**Status**: 🎉 **PROJECT COMPLETE AND FULLY FUNCTIONAL**

The Engineering Store application is fully operational with real-time inventory management, transaction recording, and audit trail capabilities. All core features have been tested and are working as expected.

*Last Updated: January 4, 2026*


---

## 🧪 Testing Scenarios

### **Test Inventory Management**
1. Login with valid credentials
2. Navigate to "Inventory Items" (Inventory Holding section)
3. Click **+** button to add new item
4. Fill in all required fields:
   - SAP Number
   - Item Name
   - Internal Reference
   - Description
   - Safety Stock Level
   - Replenishment Quantity
   - Actual Quantity
   - Rack Number
   - Rack Level
5. Item appears **instantly** in the inventory list
6. Search/filter functionality works in real-time

### **Test Real-time Synchronization**
1. Add an item in Add Item form
2. Item appears immediately in Inventory List
3. Changes are saved to Firestore instantly
4. Closing and reopening the app loads the same items

### **Test Stock Status Display**
1. View inventory items
2. Items show stock status (OUT, LOW!, or GOOD)
3. Status updates based on current quantity vs. low stock threshold
4. Color-coded indicators (Red=OUT, Orange=LOW, Green=GOOD)

---

## 📦 Dependencies

### **Firebase Stack**
- firebase_core: ^2.24.0
- firebase_auth: ^4.16.0
- cloud_firestore: ^4.17.0
- firebase_storage: ^11.6.0

### **UI & State Management**
- flutter_material_design
- provider: ^6.0.5

### **Utilities**
- google_sign_in: ^6.3.0
- intl: ^0.19.0
- excel: ^4.0.0
- http: ^1.2.0

---

## 🔑 Key Technical Decisions

### **Real-time Data Synchronization**
- **Inventory List** uses `StreamBuilder<QuerySnapshot>` for real-time Firestore updates
- Automatically rebuilds UI when data changes
- Eliminates need for manual refresh buttons
- Provides instant feedback when items are added/edited

### **Data Architecture**
- Firestore as single source of truth for all data
- No in-memory caching (all data fetched fresh from Firestore)
- Efficient field mapping between Firestore documents and Dart models

### **User Experience**
- Smooth navigation between screens
- Real-time search and filtering
- Color-coded status indicators
- Empty state messages for better UX

---

## ⚠️ Important Notes

### **Firestore Collection Requirements**
- `inventory` collection must exist (auto-created on first write)
- `users` collection created during authentication
- Both collections require proper security rules for read/write access

### **Real-time Sync Behavior**
- When you add an item via Add Item form, it appears **instantly** in the list
- Changes visible across all open app screens
- Requires active internet connection to Firestore

### **Android Emulator**
- reCAPTCHA disabled for development/testing
- Use release builds for production with full security enabled

### **Firebase Configuration**
- `google-services.json` required in `android/app/`
- Generated by `flutterfire configure` command
- Contains project-specific credentials

---

## 🐛 Troubleshooting

### **Items Not Appearing in List**
1. Check Firestore console for `inventory` collection
2. Verify security rules allow read access
3. Check app logs: `flutter logs`
4. Ensure Firebase connection is active

### **Form Validation Issues**
- All required fields must be filled
- Rack Number, Rack Level, Actual Quantity should not have pre-filled default values
- Clear error messages guide users

### **Build Failures**
```powershell
flutter clean
flutter pub get
flutter run
```

### **Firebase Connection Issues**
- Verify Firebase project ID in `google-services.json`
- Check Android device/emulator internet connection
- Review Firestore security rules

---

## 📊 Current Status

| Feature | Status | Notes |
|---------|--------|-------|
| Authentication | ✅ Complete | Email/password login working |
| Inventory List | ✅ Complete | Real-time Firestore sync active |
| Add Items | ✅ Complete | Form validation implemented |
| Edit Items | ✅ Complete | Edit functionality ready |
| Search/Filter | ✅ Complete | Real-time filtering works |
| Movement Logs | ✅ Complete | History screen available |
| Master Data | ✅ Complete | Admin options accessible |
| Stock Counting | ✅ Complete | Quick update interface ready |
| UI/UX | ✅ Complete | Material Design 3 implemented |
| Firebase Integration | ✅ Complete | Full Firestore sync active |

---

## 🔄 Development Notes

### **Code Quality**
- All screens use proper state management
- StreamBuilder for real-time data (no polling)
- Proper error handling and user feedback
- Clean separation of concerns (screens, services, models)

### **Performance Optimizations**
- Efficient Firestore queries
- No unnecessary rebuilds
- Real-time sync vs. periodic polling
- Proper disposal of resources

### **Security Considerations**
- Firebase Auth for user verification
- Firestore security rules for data access
- No sensitive data in app code
- reCAPTCHA disabled only in development

---

## 📝 Version Information

- **Flutter Version**: 3.35.6 (stable)
- **Dart Version**: 3.5.4
- **Target Platform**: Android API 34
- **Min SDK**: Android 21+
- **Build Date**: December 15, 2025

---

## 📚 Documentation References

- [Firebase Flutter Guide](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [README.md](README.md) - Detailed setup and feature guide

---

## ✅ Completion Checklist

- ✅ User authentication system
- ✅ Real-time inventory synchronization
- ✅ Add/Edit/View items
- ✅ Search and filter functionality
- ✅ Stock status indicators
- ✅ Movement tracking
- ✅ Master data management
- ✅ Admin controls
- ✅ Responsive UI design
- ✅ Error handling and validation
- ✅ Firebase integration
- ✅ Production-ready code

---

**Maintain by DevX Development Team**
