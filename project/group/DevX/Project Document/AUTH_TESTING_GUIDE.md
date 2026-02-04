# Engineering Store - Testing & Development Guide

## Complete Testing Guide for Inventory Management Features

This document provides comprehensive instructions to test all features of the Engineering Store application, including authentication, inventory management, and real-time synchronization.

---

## 🔐 Authentication Testing

### **Test Case 1: User Login**

**Purpose**: Verify Firebase authentication flow

**Prerequisites**:
- User account exists in Firebase Auth
- User document exists in Firestore `users` collection

**Steps**:
1. **Start the app** - App lands on Login Screen
2. **Enter Credentials**:
   - Email: `user@example.com`
   - Password: `YourPassword@123`
3. **Click** "SIGN IN"
4. **Expected Result**:
   - User authenticated via Firebase
   - Redirected to Home Screen
   - Home shows user name and role

---

### **Test Case 2: Password Recovery**

**Purpose**: Test forgot password functionality

**Steps**:
1. **From Login Screen**
2. **Click** "Forgot your password?" link
3. **Enter email**: `user@example.com`
4. **Click** "Reset Password"
5. **Expected**:
   - Message: "Password reset email sent" (in development)
   - Firebase sends reset link to email address
   - User can set new password via email link

---

### **Test Case 3: Logout**

**Purpose**: Test session termination

**Steps**:
1. **From Home Screen**
2. **Click** Profile icon (top-left)
3. **Select** "Sign Out"
4. **Confirm** logout
5. **Expected Result**:
   - User signed out from Firebase
   - Redirected to Login Screen
   - All session data cleared

---

## 📦 Inventory Management Testing

### **Test Case 4: View Inventory List (Real-time Sync)**

**Purpose**: Test real-time Firestore data synchronization

**Prerequisites**:
- At least one item in Firestore `inventory` collection
- User logged in with proper permissions

**Steps**:
1. **Login successfully**
2. **Navigate to**: Home → Inventory Holding → Inventory Items
3. **Wait for load**
4. **Expected Result**:
   - All items from Firestore appear instantly
   - Items show: SAP Code, Name, Quantity, Stock Status
   - Search bar available at top
   - Items display color-coded status:
     - 🟢 GREEN = Good stock (above low threshold)
     - 🟠 ORANGE = LOW! (at or below low threshold)
     - 🔴 RED = OUT (zero quantity)

---

### **Test Case 5: Add New Inventory Item**

**Purpose**: Test item creation and real-time sync to list

**Steps**:
1. **From Inventory List Screen**
2. **Click** "+" (Add button) in top-right
3. **Fill Form with**:
   - SAP Number: `7000001` (required)
   - Item Name: `Bearing 6200` (required)
   - Internal Reference: `BEA-001` (required)
   - Description: `Double row ball bearing`
   - Safety Stock Level: `50`
   - Replenishment Qty: `100`
   - Actual Quantity: `75` (required)
   - Rack Number: `A` (required)
   - Rack Level: `3` (required)
4. **Click** "ADD ITEM"
5. **Expected Result**:
   - Success message: "Item added successfully"
   - **IMMEDIATELY** returned to Inventory List
   - **NEW ITEM APPEARS AT TOP** of list (no refresh needed!)
   - Item shows in Firestore collection
   - StreamBuilder triggers automatic update

---

### **Test Case 6: Real-time Item Visibility**

**Purpose**: Verify items are visible instantly after creation

**Steps**:
1. **Add item using Test Case 5**
2. **Observe** the Inventory List in real-time
3. **Expected**:
   - Item appears without manual refresh
   - Quantity displays correctly
   - Stock status calculated and displayed
   - No delay between saving and display

---

### **Test Case 7: Search & Filter Inventory**

**Purpose**: Test search functionality on real-time data

**Prerequisites**:
- Multiple items in inventory list

**Steps**:
1. **From Inventory List**
2. **Type in search bar** the item name (e.g., "Bearing")
3. **Observe results**
4. **Clear search**
5. **Search by SAP code** (e.g., "700")
6. **Expected Result**:
   - Results filter in real-time as you type
   - Searches across: SAP Code, Item Name, Description
   - Case-insensitive matching
   - Clearing search shows all items again

---

### **Test Case 8: View Item Details**

**Purpose**: Test detailed item information screen

**Steps**:
1. **From Inventory List**
2. **Click on any item** (tap the row)
3. **Expected Result**:
   - Item Detail Screen opens
   - Shows all item information:
     - SAP Code, Name, Description
     - Current Stock, Max Stock, Replenish Qty
     - Rack Location, Rack Level
     - Last Updated timestamp
     - Recent Activity log
   - Stock status displayed with color indicator
   - Back button returns to list

---

### **Test Case 9: Edit Inventory Item**

**Purpose**: Test item editing functionality

**Prerequisites**:
- Item exists in inventory list
- Edit button/action available on detail screen

**Steps**:
1. **From Item Detail Screen**
2. **Click** "Edit" button (if available)
3. **Modify fields** (e.g., update Actual Quantity from 75 to 85)
4. **Click** "UPDATE ITEM"
5. **Expected Result**:
   - Changes saved to Firestore
   - Returned to Inventory List
   - Item reflects updated quantity
   - Stock status recalculated if quantity changed

---

## 🚚 Stock Management Testing

### **Test Case 10: Record Usage (Receive Item)**

**Purpose**: Test inventory receiving flow

**Steps**:
1. **Navigate to**: Home → Inventory Consumption → Record Usage
2. **Click** "Receive Item" button
3. **Select an item** and enter quantity received
4. **Click** "CONFIRM"
5. **Expected Result**:
   - Current stock increases
   - Movement log updated
   - Item status reflects in list

---

### **Test Case 11: Count Stock**

**Purpose**: Test physical stock counting

**Steps**:
1. **Navigate to**: Home → Inventory Consumption → Count Stock
2. **Search for item** in list
3. **Enter counted quantity**
4. **Click** "UPDATE"
5. **Expected Result**:
   - Quantity updated immediately
   - Reflected in Inventory List
   - Timestamp shows count was done

---

### **Test Case 12: View Movement Logs**

**Purpose**: Test inventory movement history

**Steps**:
1. **Navigate to**: Home → System Management → Report (Movement Logs)
2. **Observe movements** listed
3. **Expected Result**:
   - Shows all movement history
   - Displays: Type (Inbound/Outbound/Transfer)
   - Item name, quantity, timestamp
   - User who recorded movement

---

## 🎯 UI/UX Testing

### **Test Case 13: Navigation**

**Purpose**: Test navigation between screens

**Steps**:
1. **From Home Screen**
2. **Navigate to each menu item**:
   - Inventory Items → Detail → Back to List
   - Record Usage → Select option → Back
   - Movement Logs → View → Back
   - Master Data → Options → Back
3. **Expected Result**:
   - All navigation works smoothly
   - Back buttons work correctly
   - No data loss during navigation
   - State properly maintained

---

### **Test Case 14: Empty State Handling**

**Purpose**: Test app behavior with no data

**Steps**:
1. **Login to empty inventory**
2. **Navigate to Inventory Items**
3. **Expected Result**:
   - Shows "No items found" message
   - Add button still available
   - Graceful empty state display

---

### **Test Case 15: Form Validation**

**Purpose**: Test form input validation

**Steps**:
1. **Go to Add Item Screen**
2. **Try submitting empty form**
3. **Expected**: Error messages for required fields
4. **Fill SAP Number only**
5. **Try submitting**
6. **Expected**: Error for other required fields
7. **Fill all required fields correctly**
8. **Click Submit**
9. **Expected**: Form submits successfully

---

## 🔄 Real-time Synchronization Testing

### **Test Case 16: Multi-screen Sync**

**Purpose**: Verify data syncs across all open screens

**Setup**:
- Open app on emulator with Inventory List screen visible

**Steps**:
1. **Keep Inventory List open** on your emulator
2. **Add a new item** using Add Item form
3. **Return to Inventory List**
4. **Expected**:
   - Item appears instantly without refresh
   - No manual reload button needed
   - StreamBuilder automatically updates UI
   - Quantity and status calculated correctly

---

### **Test Case 17: Firebase Firestore Persistence**

**Purpose**: Verify data persists in Firestore

**Steps**:
1. **Add an item**
2. **Go to Firebase Console** → Firestore → inventory collection
3. **Expected**:
   - New document created for item
   - All fields saved correctly:
     - sapCode, name, internalRef
     - description, currentStock, maxStock
     - rackNumber, rackLevel, location
     - lastUpdated timestamp
   - Can modify document in Firestore

4. **Return to app**
5. **Expected**: App reflects Firestore changes

---

## 🧪 Error Handling Testing

### **Test Case 18: Firebase Connection Loss**

**Purpose**: Test app behavior without internet

**Steps**:
1. **Turn off emulator internet** (in settings or emulator controls)
2. **Try to load Inventory List**
3. **Try to add item**
4. **Expected Result**:
   - List shows loading state then error
   - Form submission fails gracefully
   - User-friendly error message
   - App remains stable

5. **Restore internet**
6. **Expected**: App recovers and loads data

---

### **Test Case 19: Invalid Input**

**Purpose**: Test validation for bad data

**Steps**:
1. **Add Item Screen**
2. **Enter non-numeric value** for "Actual Quantity"
3. **Try to submit**
4. **Expected**: 
   - Error message: "Must be a valid positive number"
   - Form doesn't submit
   - User can correct and retry

---

## 📊 Testing Checklist

### **Authentication** 
- [ ] User login successful
- [ ] Wrong password rejected
- [ ] Non-existent user rejected
- [ ] Password reset works
- [ ] Logout successful

### **Inventory Management**
- [ ] Inventory list loads from Firestore
- [ ] Add item saves to Firestore
- [ ] Item appears instantly in list (no refresh)
- [ ] Search filters items in real-time
- [ ] View item details works
- [ ] Edit item updates Firestore
- [ ] Stock status colors display correctly

### **Real-time Sync**
- [ ] New items visible instantly
- [ ] Changes sync without refresh
- [ ] Firestore console shows updates
- [ ] Multiple screens update simultaneously

### **Error Handling**
- [ ] Form validation works
- [ ] Network errors handled gracefully
- [ ] Invalid data rejected
- [ ] Error messages clear and helpful

### **UI/UX**
- [ ] Navigation smooth and intuitive
- [ ] All screens responsive
- [ ] Empty states display correctly
- [ ] Loading indicators shown appropriately

---

## 🐛 Troubleshooting

### **Items Not Appearing**
- Check: Firestore `inventory` collection exists
- Verify: Security rules allow read access
- Check: User has internet connection
- Review: Flutter logs for errors
```powershell
flutter logs
```

### **Real-time Updates Not Working**
- Verify: Firestore connection active
- Check: No errors in StreamBuilder
- Ensure: Internet connection stable
- Test: Restart app and check again

### **Add Item Form Won't Submit**
- Check: All required fields filled
- Verify: Actual Quantity is numeric
- Check: Firebase write permissions
- Review: Console logs for validation errors

### **Search Not Finding Items**
- Verify: Item name spelled correctly
- Try: Searching by SAP code instead
- Check: Search is case-insensitive
- Ensure: Item actually exists in Firestore

---

## 🔧 Development Testing Tips

### **View Logs**
```powershell
flutter logs
```

### **Enable Verbose Logging**
```powershell
flutter run -v
```

### **Check Firestore Directly**
1. Go to Firebase Console
2. Select your project
3. Firestore Database
4. Look at `inventory` collection documents

### **Test with Fake Data**
1. Add multiple test items
2. Test search with various terms
3. Test with large quantities
4. Test with special characters in descriptions

---

## 📝 Test Results Template

```
Test Case: [Name]
Date: [Date]
Tester: [Name]
Device: [Emulator/Physical]
OS Version: [Android Version]

Expected Result: [What should happen]
Actual Result: [What actually happened]
Status: [PASS/FAIL/BLOCKED]
Notes: [Any additional observations]
```

---

## 🚀 Continuous Testing

Run these tests regularly:
- After code changes
- Before building APK
- After Firebase configuration changes
- Before releases

---

**Last Updated**: December 15, 2025
**App Version**: 0.1.0+1
**Flutter Version**: 3.35.6
**Target Android**: API 34
