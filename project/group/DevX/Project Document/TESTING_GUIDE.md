# Engineering Store - Comprehensive Testing Guide

## Complete Testing Documentation

**Project**: Engineering Store - Inventory Management System  
**Version**: 0.1.0+1  
**Last Updated**: February 4, 2026  
**Status**: Production Testing Guide

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Test Environment Setup](#2-test-environment-setup)
3. [Authentication Testing](#3-authentication-testing)
4. [Dashboard Testing](#4-dashboard-testing)
5. [Inventory Management Testing](#5-inventory-management-testing)
6. [Transaction Recording Testing](#6-transaction-recording-testing)
7. [History & Audit Trail Testing](#7-history--audit-trail-testing)
8. [Search & Filter Testing](#8-search--filter-testing)
9. [Real-time Synchronization Testing](#9-real-time-synchronization-testing)
10. [UI/UX Testing](#10-uiux-testing)
11. [Error Handling Testing](#11-error-handling-testing)
12. [Performance Testing](#12-performance-testing)
13. [Security Testing](#13-security-testing)
14. [Integration Testing](#14-integration-testing)
15. [Testing Checklist](#15-testing-checklist)
16. [Test Reports](#16-test-reports)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Introduction

### 1.1 Purpose

This document provides comprehensive testing procedures for the Engineering Store Inventory Management System. It covers all features, from basic functionality to advanced scenarios.

### 1.2 Scope

**In Scope**:
- Functional testing of all features
- UI/UX testing
- Integration testing with Firebase
- Performance testing
- Security testing
- Error handling testing

**Out of Scope**:
- Automated testing (future enhancement)
- Load testing (future enhancement)
- iOS testing (not applicable)

### 1.3 Test Approach

- **Manual Testing**: Primary approach for all test cases
- **Black Box Testing**: Testing from user perspective
- **Real Device Testing**: Testing on physical Android devices
- **Emulator Testing**: Testing on Android emulators

### 1.4 Test Levels

1. **Unit Testing**: Individual component testing (future)
2. **Integration Testing**: Component interaction testing
3. **System Testing**: Complete application testing ✅
4. **Acceptance Testing**: User acceptance validation ✅

---

## 2. Test Environment Setup

### 2.1 Prerequisites

**Software Requirements**:
- Flutter SDK 3.35.6 or higher
- Android Studio with Android SDK
- Android emulator (Pixel 5 API 34) or physical device
- Firebase project with test data
- Git for version control

**Hardware Requirements**:
- Development machine with minimum 8GB RAM
- Android device (API 21+) or emulator
- Stable internet connection

### 2.2 Setup Steps

#### Step 1: Install Flutter
```powershell
# Verify Flutter installation
flutter doctor
flutter --version
```

#### Step 2: Configure Project
```powershell
cd "C:\Users\SYAZWAN\OneDrive\Documents\GitHub\mobile_apps\project\group\DevX\engineering_store"
flutter pub get
```

#### Step 3: Launch Emulator
```powershell
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_5_API_34
```

#### Step 4: Run Application
```powershell
flutter run
```

### 2.3 Test Data Preparation

**Firebase Test Users**:
1. Admin user: `admin@test.com` / `admin123`
2. Storekeeper user: `storekeeper@test.com` / `store123`
3. Technician user: `tech@test.com` / `tech123`

**Test Inventory Items**:
- At least 10 items with varying stock levels
- Items with stock > 5 (GOOD status)
- Items with stock 1-5 (LOW! status)
- Items with stock 0 (OUT status)

---

## 3. Authentication Testing

### Test Case AUTH-001: Valid User Login

**Objective**: Verify user can login with valid credentials

**Preconditions**:
- User account exists in Firebase Auth
- User document exists in Firestore `users` collection

**Test Steps**:
1. Launch application
2. Verify Login Screen is displayed
3. Enter email: `storekeeper@test.com`
4. Enter password: `store123`
5. Tap "SIGN IN" button
6. Wait for authentication

**Expected Results**:
- ✅ Authentication successful
- ✅ Redirected to Home Screen
- ✅ Welcome message displays username
- ✅ Dashboard shows real-time statistics
- ✅ No error messages

**Actual Results**: ________________

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-002: Invalid Password

**Objective**: Verify system rejects invalid password

**Test Steps**:
1. From Login Screen
2. Enter email: `storekeeper@test.com`
3. Enter password: `wrongpassword`
4. Tap "SIGN IN" button

**Expected Results**:
- ✅ Authentication fails
- ✅ Error message displayed: "Wrong password"
- ✅ User remains on Login Screen
- ✅ Can retry with correct password

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-003: Non-existent User

**Objective**: Verify system rejects non-existent users

**Test Steps**:
1. From Login Screen
2. Enter email: `nonexistent@test.com`
3. Enter password: `anypassword`
4. Tap "SIGN IN" button

**Expected Results**:
- ✅ Authentication fails
- ✅ Error message: "No user found for that email"
- ✅ User remains on Login Screen
- ✅ Can try different credentials

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-004: Password Reset

**Objective**: Verify password reset functionality

**Test Steps**:
1. From Login Screen
2. Tap "Forgot your password?" link
3. Enter email: `storekeeper@test.com`
4. Tap "Reset Password" button
5. Check email inbox

**Expected Results**:
- ✅ Reset screen displayed
- ✅ Success message shown
- ✅ Firebase sends reset email
- ✅ Email contains reset link
- ✅ Link works to set new password

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-005: User Logout

**Objective**: Verify logout functionality and session termination

**Test Steps**:
1. Login successfully to Home Screen
2. Tap Profile icon (top-right)
3. Select "Sign Out" from menu
4. Confirm logout if prompted

**Expected Results**:
- ✅ User signed out from Firebase
- ✅ Redirected to Login Screen
- ✅ Session cleared
- ✅ Cannot access app without re-login
- ✅ Back button doesn't return to logged-in state

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-006: Session Persistence

**Objective**: Verify user session persists across app restarts

**Test Steps**:
1. Login successfully
2. Navigate to Home Screen
3. Close app completely (kill from recent apps)
4. Relaunch app

**Expected Results**:
- ✅ User still logged in
- ✅ Immediately shows Home Screen
- ✅ No login screen displayed
- ✅ User data accessible

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case AUTH-007: Email Validation

**Objective**: Verify email format validation

**Test Steps**:
1. From Login Screen
2. Enter invalid email: `invalidemail`
3. Try to login
4. Enter email: `test@`
5. Try to login

**Expected Results**:
- ✅ Error message for invalid format
- ✅ Form validation prevents submission
- ✅ Error clears when valid email entered
- ✅ Can submit with valid email format

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 4. Dashboard Testing

### Test Case DASH-001: Dashboard Statistics Display

**Objective**: Verify dashboard displays correct real-time statistics

**Preconditions**:
- User logged in
- Test inventory data exists with known quantities

**Test Steps**:
1. Login and view Home Screen
2. Observe Dashboard Overview section
3. Note the three statistic cards:
   - Total Items
   - Low Stock
   - Out of Stock

**Expected Results**:
- ✅ Total Items shows correct count of all inventory items
- ✅ Low Stock shows count of items with 1-5 units
- ✅ Out of Stock shows count of items with 0 units
- ✅ Numbers match Firestore database counts
- ✅ Statistics update in real-time

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case DASH-002: Statistics Card Navigation

**Objective**: Verify clicking statistics cards navigates to inventory list

**Test Steps**:
1. From Home Screen Dashboard
2. Tap on "Total Items" card
3. Note navigation result
4. Return to Home Screen
5. Repeat for other stat cards (future feature)

**Expected Results**:
- ✅ Total Items card is clickable
- ✅ Navigates to Inventory List screen
- ✅ Back button returns to dashboard
- ✅ Navigation is smooth

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case DASH-003: Quick Action Buttons

**Objective**: Verify quick action buttons navigate to correct screens

**Test Steps**:
1. From Home Screen
2. Tap "Receive Item" quick action button
3. Verify destination screen
4. Navigate back to Home
5. Tap "Issue Item" quick action button
6. Verify destination screen

**Expected Results**:
- ✅ "Receive Item" navigates to Receive Item Screen
- ✅ "Issue Item" navigates to Issue Item Screen
- ✅ Buttons are clearly visible
- ✅ Icons are appropriate
- ✅ Navigation is instant

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case DASH-004: Real-time Dashboard Updates

**Objective**: Verify dashboard statistics update automatically

**Test Steps**:
1. Note current dashboard statistics
2. Navigate to Inventory List
3. Add a new item
4. Return to dashboard (or keep dashboard visible)
5. Observe Total Items count

**Expected Results**:
- ✅ Total Items count increases by 1
- ✅ Update happens automatically (no refresh needed)
- ✅ Update happens within 2 seconds
- ✅ Other statistics update if applicable

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 5. Inventory Management Testing

### Test Case INV-001: View Inventory List

**Objective**: Verify inventory list displays all items with real-time sync

**Preconditions**:
- At least 5 test items in Firestore inventory collection

**Test Steps**:
1. Login successfully
2. Navigate to: Home → Inventory Holding → Inventory Items
3. Wait for data to load
4. Observe displayed items

**Expected Results**:
- ✅ All items from Firestore displayed
- ✅ Items load within 1 second
- ✅ Each item card shows:
  - SAP Code
  - Item Name
  - Current Stock quantity
  - Stock Status badge (color-coded)
- ✅ Items sorted by lastUpdated (newest first)
- ✅ Search bar visible at top
- ✅ Add (+) button visible
- ✅ Scroll works smoothly

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-002: Add New Item

**Objective**: Verify new item creation and real-time synchronization

**Test Steps**:
1. From Inventory List Screen
2. Tap "+" (Add) button
3. Fill in form fields:
   - SAP Number: `TEST001`
   - Item Name: `Test Bearing`
   - Internal Reference: `TB-001`
   - Description: `Test item for QA`
   - Safety Stock Level: `50`
   - Replenishment Qty: `100`
   - Actual Quantity: `75`
   - Rack Number: `A`
   - Rack Level: `3`
4. Tap "ADD ITEM" button
5. Observe result

**Expected Results**:
- ✅ Form submitted successfully
- ✅ Success message displayed
- ✅ Navigated back to Inventory List
- ✅ New item appears immediately at top of list
- ✅ Item shows in Firestore collection
- ✅ Location auto-generated: "Rack A, Level 3"
- ✅ Stock status badge shows "GOOD" (green)
- ✅ No page refresh needed

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-003: Form Validation

**Objective**: Verify required field validation on add item form

**Test Steps**:
1. Open Add Item Screen
2. Leave all fields empty
3. Tap "ADD ITEM"
4. Observe validation
5. Fill only SAP Number
6. Tap "ADD ITEM"
7. Observe validation
8. Fill all required fields
9. Tap "ADD ITEM"

**Expected Results**:
- ✅ Empty form shows validation errors
- ✅ Error messages appear below each required field
- ✅ Error messages are clear and specific
- ✅ Partial completion still shows remaining errors
- ✅ All required fields validated:
  - SAP Number
  - Item Name
  - Internal Reference
  - Actual Quantity
  - Rack Number
  - Rack Level
- ✅ Form submits only when all required fields valid

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-004: Edit Existing Item

**Objective**: Verify item editing functionality and real-time update

**Preconditions**:
- Item exists in inventory list

**Test Steps**:
1. From Inventory List
2. Tap on any item to view details
3. Tap "Edit Item" button (if available on detail screen)
   - OR navigate to edit screen via menu
4. Modify Actual Quantity: Change from 75 to 85
5. Modify Description: Add "Updated"
6. Tap "UPDATE ITEM"
7. Observe result

**Expected Results**:
- ✅ Edit screen opens with pre-filled data
- ✅ All fields editable
- ✅ Changes saved successfully
- ✅ Success message displayed
- ✅ Navigated back to list or detail
- ✅ Changes reflected immediately in list
- ✅ Firestore document updated
- ✅ Stock status recalculated if needed

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-005: View Item Details

**Objective**: Verify detailed item information display

**Test Steps**:
1. From Inventory List
2. Tap on any item card
3. Observe Item Detail Screen

**Expected Results**:
- ✅ Detail screen opens
- ✅ All item information displayed:
  - SAP Code
  - Item Name
  - Internal Reference
  - Description
  - Current Stock
  - Safety Stock Level
  - Replenishment Quantity
  - Rack Number
  - Rack Level
  - Location (formatted)
  - Last Updated timestamp
- ✅ Stock status badge visible (color-coded)
- ✅ Action buttons available (Edit, Adjust Stock)
- ✅ Back button returns to list

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-006: Delete Single Item

**Objective**: Verify single item deletion with confirmation

**Test Steps**:
1. From Inventory List
2. Long-press on any item
3. Observe delete option
4. Select delete
5. Observe confirmation dialog
6. Confirm deletion
7. Observe result

**Expected Results**:
- ✅ Long-press shows delete option
- ✅ Confirmation dialog displayed
- ✅ Dialog has "Cancel" and "Delete" options
- ✅ Cancel keeps item
- ✅ Delete removes item from list
- ✅ Item removed from Firestore
- ✅ List updates immediately
- ✅ Success message shown

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-007: Delete Multiple Items (Bulk Delete)

**Objective**: Verify bulk deletion functionality

**Test Steps**:
1. From Inventory List
2. Enable selection mode (if available)
3. Select multiple items using checkboxes
4. Tap delete button
5. Observe confirmation dialog
6. Confirm deletion
7. Observe result

**Expected Results**:
- ✅ Checkbox selection mode works
- ✅ Can select multiple items
- ✅ Selected count displayed
- ✅ Confirmation dialog shows count
- ✅ All selected items deleted
- ✅ Items removed from Firestore
- ✅ List updates immediately
- ✅ Success message shown

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INV-008: Stock Status Indicators

**Objective**: Verify stock status calculation and color coding

**Preconditions**:
- Items with varying stock levels:
  - Item with 0 units
  - Item with 1-5 units
  - Item with > 5 units

**Test Steps**:
1. From Inventory List
2. Observe each item's stock status badge
3. Check color coding matches stock level

**Expected Results**:
- ✅ OUT status (0 units):
  - Badge shows "OUT"
  - Badge color is RED
- ✅ LOW! status (1-5 units):
  - Badge shows "LOW!"
  - Badge color is ORANGE
- ✅ GOOD status (>5 units):
  - Badge shows "GOOD"
  - Badge color is GREEN
- ✅ Status matches actual stock quantity
- ✅ Status updates when stock changes

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 6. Transaction Recording Testing

### Test Case TRANS-001: Receive Items from Supplier

**Objective**: Verify receiving transaction and stock update

**Preconditions**:
- At least one item in inventory
- Note item's current stock quantity

**Test Steps**:
1. Navigate to: Home → Quick Actions → Receive Item
   - OR: Home → Inventory Consumption → Record Usage → Receive Item
2. Select SAP Number from dropdown
3. Observe auto-filled Item Name
4. Enter Quantity Received: `10`
5. Enter Supplier Name: `ABC Supplies`
6. Enter Remarks: `Monthly delivery`
7. Tap "CONFIRM" button
8. Observe result
9. Navigate to Inventory List
10. Find the received item
11. Check stock quantity

**Expected Results**:
- ✅ Form submitted successfully
- ✅ Success message displayed
- ✅ Transaction saved to `receivings` collection
- ✅ Movement log created in `movement_logs` (type: Inbound)
- ✅ Inventory stock increased by 10
- ✅ Stock update visible immediately in list
- ✅ Timestamp recorded
- ✅ Form reset for next entry

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case TRANS-002: Issue Items to Technician

**Objective**: Verify issuance transaction and stock validation

**Preconditions**:
- Item in inventory with sufficient stock (at least 5 units)
- Note item's current stock quantity

**Test Steps**:
1. Navigate to: Home → Quick Actions → Issue Item
   - OR: Home → Inventory Consumption → Record Usage → Issue Item
2. Select SAP Number from dropdown
3. Observe auto-filled Item Name
4. Enter Quantity Needed: `5`
5. Enter Usage Location: `Workshop Area 2`
6. Enter Technician Name: `John Doe`
7. Enter Remarks: `Maintenance work`
8. Tap "CONFIRM" button
9. Observe result
10. Check inventory stock

**Expected Results**:
- ✅ Form submitted successfully
- ✅ Success message displayed
- ✅ Transaction saved to `issuance` collection
- ✅ Movement log created in `movement_logs` (type: Outbound)
- ✅ Inventory stock decreased by 5
- ✅ Stock update visible immediately in list
- ✅ Timestamp recorded
- ✅ Form reset for next entry

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case TRANS-003: Prevent Over-Issuing

**Objective**: Verify system prevents issuing more than available stock

**Preconditions**:
- Item with known stock quantity (e.g., 3 units)

**Test Steps**:
1. Navigate to Issue Item Screen
2. Select item with 3 units stock
3. Enter Quantity Needed: `5` (more than available)
4. Fill other required fields
5. Tap "CONFIRM"
6. Observe result

**Expected Results**:
- ✅ Validation error displayed
- ✅ Error message: "Insufficient stock. Available: 3"
- ✅ Transaction NOT saved
- ✅ Stock NOT decreased
- ✅ Form remains open for correction
- ✅ User can reduce quantity and retry

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case TRANS-004: Transaction with Zero Stock Item

**Objective**: Verify can receive items even when stock is zero

**Preconditions**:
- Item with 0 stock

**Test Steps**:
1. Navigate to Receive Item Screen
2. Select item with 0 stock
3. Enter Quantity Received: `20`
4. Fill other fields
5. Submit transaction
6. Check inventory

**Expected Results**:
- ✅ Transaction successful
- ✅ Stock increased from 0 to 20
- ✅ Stock status changed from OUT to GOOD
- ✅ Stock status badge color updated

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 7. History & Audit Trail Testing

### Test Case HIST-001: View Usage History

**Objective**: Verify usage history displays all transactions

**Preconditions**:
- At least one receiving and one issuance transaction recorded

**Test Steps**:
1. Navigate to: Home → Inventory Consumption → Usage History
2. Observe transaction list
3. Check filter options

**Expected Results**:
- ✅ All transactions displayed
- ✅ Both receiving and issuance visible
- ✅ Filter chips available: All, Receiving, Issuance
- ✅ Each transaction shows:
  - Transaction type (Receiving/Issuance)
  - Item name
  - Quantity
  - Date/time
  - Additional info (supplier/technician)
- ✅ Sorted chronologically (newest first)
- ✅ Real-time updates

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case HIST-002: Filter Usage History

**Objective**: Verify filtering transactions by type

**Test Steps**:
1. From Usage History Screen
2. Tap "Receiving" filter chip
3. Observe filtered list
4. Tap "Issuance" filter chip
5. Observe filtered list
6. Tap "All" filter chip
7. Observe full list

**Expected Results**:
- ✅ "Receiving" shows only receiving transactions
- ✅ "Issuance" shows only issuance transactions
- ✅ "All" shows both types
- ✅ Filter updates list immediately
- ✅ Active filter chip highlighted
- ✅ Transaction count matches filter

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case HIST-003: View Movement Logs

**Objective**: Verify complete audit trail visibility

**Test Steps**:
1. Navigate to: Home → System Management → Movement Logs
2. Observe movement list
3. Check filter options

**Expected Results**:
- ✅ All movements displayed
- ✅ Inbound and Outbound movements visible
- ✅ Filter options available
- ✅ Each movement shows:
  - Movement type (Inbound/Outbound)
  - SAP Code
  - Item name
  - Quantity
  - Source/destination
  - Timestamp
  - User info
- ✅ Complete audit trail
- ✅ Real-time updates

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case HIST-004: Movement Log Filtering

**Objective**: Verify filtering movement logs by type

**Test Steps**:
1. From Movement Logs Screen
2. Tap "Inbound" filter
3. Observe filtered list
4. Tap "Outbound" filter
5. Observe filtered list
6. Tap "All" filter
7. Observe full list

**Expected Results**:
- ✅ "Inbound" shows only receiving movements
- ✅ "Outbound" shows only issuance movements
- ✅ "All" shows both types
- ✅ Filter updates list immediately
- ✅ Movement count matches filter

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 8. Search & Filter Testing

### Test Case SEARCH-001: Search by Item Name

**Objective**: Verify search functionality filters items correctly

**Preconditions**:
- Multiple items in inventory with varied names

**Test Steps**:
1. From Inventory List
2. Tap search bar
3. Type: "Bearing"
4. Observe results
5. Type: "Bear"
6. Observe results

**Expected Results**:
- ✅ Search filters list in real-time
- ✅ Results show items matching "Bearing"
- ✅ Partial match "Bear" also shows "Bearing"
- ✅ Search is case-insensitive
- ✅ Non-matching items hidden
- ✅ Search is instant (< 100ms)

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEARCH-002: Search by SAP Code

**Objective**: Verify search works with SAP codes

**Test Steps**:
1. From Inventory List
2. In search bar, type SAP code: "7000"
3. Observe results
4. Type complete SAP: "7000001"
5. Observe results

**Expected Results**:
- ✅ Partial SAP code matches items
- ✅ Complete SAP code shows exact item
- ✅ Search works for numeric codes
- ✅ Results update as you type

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEARCH-003: Search by Description

**Objective**: Verify search includes item descriptions

**Test Steps**:
1. From Inventory List
2. Type word from item description
3. Observe results

**Expected Results**:
- ✅ Items with matching description shown
- ✅ Search covers all three fields:
  - SAP Code
  - Item Name
  - Description
- ✅ Results accurate

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEARCH-004: Clear Search

**Objective**: Verify clearing search shows all items

**Test Steps**:
1. From Inventory List with active search
2. Tap clear button (X) in search bar
3. Observe result

**Expected Results**:
- ✅ Search text cleared
- ✅ All items displayed again
- ✅ Item count returns to total
- ✅ Search bar ready for new search

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEARCH-005: Search with No Results

**Objective**: Verify behavior when search finds no matches

**Test Steps**:
1. From Inventory List
2. Type non-existent search term: "xyz123abc"
3. Observe result

**Expected Results**:
- ✅ Empty list displayed
- ✅ "No items found" message shown
- ✅ Clear search option available
- ✅ No errors or crashes

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 9. Real-time Synchronization Testing

### Test Case SYNC-001: Real-time List Updates

**Objective**: Verify list updates automatically when data changes

**Test Steps**:
1. Open Inventory List on device/emulator
2. Keep list visible
3. Add new item via Add Item form
4. Return to list (or observe if already visible)
5. Note the new item appearance

**Expected Results**:
- ✅ New item appears without manual refresh
- ✅ Item appears within 2 seconds
- ✅ No refresh button needed
- ✅ StreamBuilder triggers update
- ✅ List scroll position maintained

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SYNC-002: Dashboard Real-time Updates

**Objective**: Verify dashboard stats update automatically

**Test Steps**:
1. Note current dashboard statistics
2. Navigate to inventory and add item
3. Return to dashboard (or observe if visible)
4. Note updated statistics

**Expected Results**:
- ✅ Total Items count increased
- ✅ Update automatic (no refresh)
- ✅ Update within 2 seconds
- ✅ Low/Out of Stock updated if applicable

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SYNC-003: Stock Update Synchronization

**Objective**: Verify stock changes sync across all screens

**Test Steps**:
1. Note item stock in Inventory List
2. Perform receive transaction
3. Return to Inventory List
4. View Item Details
5. Check dashboard statistics

**Expected Results**:
- ✅ Stock updated in Inventory List
- ✅ Stock updated in Item Details
- ✅ Dashboard statistics reflect change
- ✅ All updates happen automatically
- ✅ Stock status badge updates if needed

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SYNC-004: Firestore Persistence Verification

**Objective**: Verify data persists in Firestore database

**Test Steps**:
1. Add new item in app
2. Open Firebase Console
3. Navigate to Firestore Database
4. Open `inventory` collection
5. Find newly added item
6. Verify all fields

**Expected Results**:
- ✅ Item document exists in Firestore
- ✅ All fields saved correctly:
  - sapCode
  - name
  - internalRef
  - description
  - currentStock
  - maxStock
  - replenishQty
  - rackNumber
  - rackLevel
  - location
  - lastUpdated (timestamp)
- ✅ Data types correct
- ✅ Timestamp generated by server

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SYNC-005: Multi-Device Synchronization

**Objective**: Verify changes sync across multiple devices

**Prerequisites**:
- Two devices logged in with same or different accounts

**Test Steps**:
1. Login on Device A
2. Login on Device B
3. On Device A, add new item
4. On Device B, observe Inventory List

**Expected Results**:
- ✅ New item appears on Device B
- ✅ Update happens automatically
- ✅ No manual refresh needed
- ✅ Both devices show same data
- ✅ Synchronization within 2 seconds

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 10. UI/UX Testing

### Test Case UI-001: Screen Navigation

**Objective**: Verify smooth navigation between all screens

**Test Steps**:
1. From Home Screen, navigate to each menu option:
   - Inventory Holding → Inventory Items
   - Inventory Consumption → Record Usage
   - Inventory Consumption → Usage History
   - System Management → Movement Logs
   - System Management → Master Data
2. Use back button to return
3. Test deep navigation (Home → Inventory → Detail → Edit)

**Expected Results**:
- ✅ All navigation works smoothly
- ✅ Screen transitions < 300ms
- ✅ Back button works correctly
- ✅ Navigation stack maintained
- ✅ No data loss during navigation
- ✅ State preserved appropriately

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-002: Empty State Display

**Objective**: Verify proper empty state handling

**Test Steps**:
1. Login to app with empty inventory
2. Navigate to Inventory List
3. Observe empty state
4. Navigate to Usage History (with no transactions)
5. Observe empty state

**Expected Results**:
- ✅ "No items found" message displayed
- ✅ Add button still visible and functional
- ✅ Empty state not confusing
- ✅ Appropriate icon or illustration
- ✅ No errors or crashes

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-003: Loading Indicators

**Objective**: Verify loading states displayed appropriately

**Test Steps**:
1. Launch app (observe initial loading)
2. Navigate to Inventory List (observe loading)
3. Submit form (observe loading during save)
4. Note all loading indicators

**Expected Results**:
- ✅ Loading indicator shown during data fetch
- ✅ Circular progress indicator displayed
- ✅ Loading doesn't block entire screen unnecessarily
- ✅ Loading clears when data loads
- ✅ Loading shown for operations > 500ms

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-004: Success/Error Messages

**Objective**: Verify user feedback for actions

**Test Steps**:
1. Add new item successfully
2. Note success message
3. Try to submit invalid form
4. Note error messages
5. Perform successful transaction
6. Note feedback

**Expected Results**:
- ✅ Success messages displayed in Snackbar
- ✅ Success message clear and concise
- ✅ Error messages specific and helpful
- ✅ Messages auto-dismiss after few seconds
- ✅ Messages don't block interaction
- ✅ Error messages actionable

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-005: Responsive Layout

**Objective**: Verify UI adapts to different screen sizes

**Test Steps**:
1. Test on phone (5-6 inch screen)
2. Test on tablet (9-10 inch screen)
3. Rotate device (portrait/landscape)
4. Check all screens

**Expected Results**:
- ✅ UI adapts to screen size
- ✅ No overlapping elements
- ✅ Touch targets accessible
- ✅ Text readable at all sizes
- ✅ Layout makes sense in landscape
- ✅ Scroll works when needed

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-006: Touch Target Size

**Objective**: Verify touch targets meet accessibility standards

**Test Steps**:
1. Use app on physical device
2. Tap all buttons, links, and interactive elements
3. Check if easy to tap accurately

**Expected Results**:
- ✅ All buttons at least 48x48 dp
- ✅ Easy to tap without mistakes
- ✅ Adequate spacing between elements
- ✅ No accidental taps

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case UI-007: Color Contrast

**Objective**: Verify readable color contrast

**Test Steps**:
1. Review all screens
2. Check text on backgrounds
3. Check status badge colors

**Expected Results**:
- ✅ Text readable on all backgrounds
- ✅ Status badges clearly distinguishable:
  - Red (OUT)
  - Orange (LOW!)
  - Green (GOOD)
- ✅ Buttons clearly visible
- ✅ Meets accessibility standards

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 11. Error Handling Testing

### Test Case ERROR-001: Network Disconnection

**Objective**: Verify app behavior without internet connection

**Test Steps**:
1. Connect device/emulator to internet
2. Login to app
3. Navigate to Inventory List
4. Turn off WiFi/data (airplane mode)
5. Try to load inventory
6. Try to add item
7. Reconnect internet
8. Observe recovery

**Expected Results**:
- ✅ Shows loading then error message
- ✅ Error message: "No internet connection" or similar
- ✅ App doesn't crash
- ✅ User can retry
- ✅ App recovers when internet restored
- ✅ Data loads automatically after reconnection

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case ERROR-002: Invalid Form Data

**Objective**: Verify handling of invalid input

**Test Steps**:
1. Go to Add Item Screen
2. Enter invalid data:
   - Letters in quantity field
   - Special characters in SAP code
   - Negative numbers
   - Very long text
3. Try to submit
4. Observe validation

**Expected Results**:
- ✅ Validation catches all invalid inputs
- ✅ Specific error messages displayed
- ✅ Form doesn't submit with invalid data
- ✅ User can correct and retry
- ✅ No crashes or unexpected behavior

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case ERROR-003: Firestore Permission Denied

**Objective**: Verify handling of security rule violations (if applicable)

**Test Steps**:
1. (If possible) Configure test to trigger permission denied
2. Observe app behavior
3. Check error messaging

**Expected Results**:
- ✅ Error caught gracefully
- ✅ User-friendly error message
- ✅ App doesn't crash
- ✅ User can take corrective action

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case ERROR-004: Duplicate SAP Code

**Objective**: Verify handling of duplicate item IDs

**Test Steps**:
1. Note existing SAP code
2. Try to add new item with same SAP code
3. Observe result

**Expected Results**:
- ✅ Duplicate detected
- ✅ Error message displayed
- ✅ Item not added
- ✅ User prompted to change SAP code

*Note: Current implementation may not enforce uniqueness. Test actual behavior.*

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 12. Performance Testing

### Test Case PERF-001: App Launch Time

**Objective**: Measure time from app icon tap to usable screen

**Test Steps**:
1. Close app completely
2. Use stopwatch
3. Tap app icon
4. Measure time to Login Screen or Home Screen

**Expected Results**:
- ✅ App launches within 2 seconds
- ✅ On modern device (4GB RAM, quad-core)

**Actual Time**: __________ seconds

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case PERF-002: Data Load Time

**Objective**: Measure inventory list load time

**Prerequisites**:
- Database with 100+ items

**Test Steps**:
1. Navigate to Inventory List (closed state)
2. Measure time from screen open to full data display
3. Repeat 3 times, average the results

**Expected Results**:
- ✅ Data loads within 1 second
- ✅ For up to 1000 items

**Actual Time**: __________ seconds (average)

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case PERF-003: Search Response Time

**Objective**: Measure search filter performance

**Test Steps**:
1. Open Inventory List with many items
2. Type in search bar
3. Observe how quickly results filter

**Expected Results**:
- ✅ Results appear instantly (< 100ms)
- ✅ No lag while typing
- ✅ Smooth filtering

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case PERF-004: Scroll Performance

**Objective**: Verify smooth scrolling with large datasets

**Prerequisites**:
- Inventory list with 100+ items

**Test Steps**:
1. Open Inventory List
2. Scroll rapidly up and down
3. Observe smoothness

**Expected Results**:
- ✅ Smooth scrolling
- ✅ No frame drops
- ✅ No lag or stuttering
- ✅ 60 FPS maintained

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 13. Security Testing

### Test Case SEC-001: Authentication Required

**Objective**: Verify unauthenticated users cannot access app

**Test Steps**:
1. Logout completely
2. Try to access app features directly (if possible)
3. Verify redirect to login

**Expected Results**:
- ✅ Auth gate prevents access
- ✅ All features require login
- ✅ Redirect to Login Screen

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEC-002: Password Security

**Objective**: Verify password is not visible

**Test Steps**:
1. Enter password on Login Screen
2. Observe password field
3. Check logs (if dev mode)

**Expected Results**:
- ✅ Password masked with dots/asterisks
- ✅ Password not visible in plain text
- ✅ Password not logged in console

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case SEC-003: Session Timeout (If Implemented)

**Objective**: Verify inactive session times out

**Test Steps**:
1. Login to app
2. Leave app idle for extended period
3. Try to use app after idle time

**Expected Results**:
- If session timeout implemented:
  - ✅ Session expires after timeout
  - ✅ User required to re-login
- If not implemented:
  - Note for future enhancement

**Status**: ☐ Pass ☐ Fail ☐ Blocked ☐ N/A

---

### Test Case SEC-004: Data Access Control

**Objective**: Verify users only see their authorized data

**Prerequisites**:
- Different user roles (Admin, Storekeeper, Technician)

**Test Steps**:
1. Login as Technician
2. Try to access admin functions
3. Verify restrictions

**Expected Results**:
- ✅ Role-based access enforced
- ✅ UI hides unauthorized functions
- ✅ Backend enforces permissions (Firestore rules)

*Note: Test actual role restrictions if implemented*

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 14. Integration Testing

### Test Case INT-001: Firebase Authentication Integration

**Objective**: Verify complete auth flow with Firebase

**Test Steps**:
1. Login with valid credentials
2. Check Firebase Console → Authentication
3. Verify user appears in Firebase Auth
4. Logout
5. Verify session cleared

**Expected Results**:
- ✅ User authenticated via Firebase
- ✅ User shows in Firebase Console
- ✅ Auth token generated
- ✅ Logout works properly

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INT-002: Firestore Integration

**Objective**: Verify bi-directional Firestore sync

**Test Steps**:
1. Add item in app
2. Check Firebase Console → Firestore
3. Verify item document exists
4. Manually edit item in Firestore Console
5. Check app (should reflect edit)

**Expected Results**:
- ✅ Write from app saves to Firestore
- ✅ Reads from Firestore display in app
- ✅ Real-time sync both directions
- ✅ Data consistency maintained

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

### Test Case INT-003: Multi-Collection Transactions

**Objective**: Verify transactions save to multiple collections

**Test Steps**:
1. Perform receive item transaction
2. Check Firebase Console:
   - `receivings` collection
   - `movement_logs` collection
   - `inventory` collection (stock updated)
3. Verify all updates

**Expected Results**:
- ✅ Document in receivings collection
- ✅ Document in movement_logs collection
- ✅ Inventory stock updated
- ✅ All updates atomic
- ✅ Timestamps consistent

**Status**: ☐ Pass ☐ Fail ☐ Blocked

---

## 15. Testing Checklist

### Authentication Module
- [ ] Valid user login
- [ ] Invalid password rejected
- [ ] Non-existent user rejected
- [ ] Password reset works
- [ ] Logout successful
- [ ] Session persistence
- [ ] Email validation

### Dashboard Module
- [ ] Statistics display correctly
- [ ] Real-time updates work
- [ ] Card navigation works
- [ ] Quick actions work

### Inventory Management Module
- [ ] Inventory list displays
- [ ] Add item works
- [ ] Form validation works
- [ ] Edit item works
- [ ] View details works
- [ ] Delete item works
- [ ] Bulk delete works
- [ ] Stock status correct
- [ ] Real-time sync works

### Transaction Module
- [ ] Receive items works
- [ ] Issue items works
- [ ] Stock validation works
- [ ] Over-issue prevention works
- [ ] Transactions save correctly

### History Module
- [ ] Usage history displays
- [ ] History filtering works
- [ ] Movement logs display
- [ ] Log filtering works

### Search & Filter Module
- [ ] Search by name works
- [ ] Search by SAP code works
- [ ] Search by description works
- [ ] Clear search works
- [ ] No results handled

### Real-time Sync Module
- [ ] List updates automatically
- [ ] Dashboard updates automatically
- [ ] Stock updates sync
- [ ] Multi-device sync works
- [ ] Firestore persistence verified

### UI/UX Module
- [ ] Navigation smooth
- [ ] Empty states correct
- [ ] Loading indicators shown
- [ ] Messages appropriate
- [ ] Responsive layout
- [ ] Touch targets adequate
- [ ] Colors accessible

### Error Handling Module
- [ ] Network errors handled
- [ ] Invalid data handled
- [ ] Permission errors handled
- [ ] Duplicate handling

### Performance Module
- [ ] App launches quickly
- [ ] Data loads quickly
- [ ] Search is instant
- [ ] Scrolling smooth

### Security Module
- [ ] Authentication required
- [ ] Password hidden
- [ ] Session management works
- [ ] Access control enforced

### Integration Module
- [ ] Firebase Auth integrated
- [ ] Firestore integrated
- [ ] Multi-collection transactions work

---

## 16. Test Reports

### Test Execution Summary Template

```
=== TEST EXECUTION SUMMARY ===

Project: Engineering Store
Version: 0.1.0+1
Test Date: ______________
Tester: ______________
Device: ______________
OS Version: ______________

Total Test Cases: ___
Passed: ___
Failed: ___
Blocked: ___
Not Applicable: ___

Pass Rate: ____%

=== DEFECTS FOUND ===

Defect ID | Severity | Module | Description | Status
---------|----------|--------|-------------|--------
DEF-001  |          |        |             |
DEF-002  |          |        |             |

=== NOTES ===
[Add any additional notes or observations]

=== SIGN-OFF ===
Tester: ______________
Date: ______________
```

### Bug Report Template

```
=== BUG REPORT ===

Bug ID: BUG-___
Date Found: ______________
Found By: ______________

Title: [Brief description]

Severity: [ ] Critical [ ] High [ ] Medium [ ] Low

Module: ______________

Steps to Reproduce:
1.
2.
3.

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Attachments:
[ ] Screenshot
[ ] Video
[ ] Logs

Environment:
- Device: ______________
- OS Version: ______________
- App Version: ______________

Status: [ ] New [ ] In Progress [ ] Fixed [ ] Closed

Notes:
[Additional information]
```

---

## 17. Troubleshooting

### Common Issues and Solutions

#### Issue: Items Not Appearing in List

**Symptoms**:
- Inventory list shows loading then empty
- Data exists in Firestore

**Troubleshooting Steps**:
1. Check Firestore Console - verify `inventory` collection has data
2. Verify security rules allow read access
3. Check app logs: `flutter logs`
4. Verify user is authenticated
5. Check internet connection
6. Restart app

**Solution**:
- If security rules issue: Update Firestore rules
- If auth issue: Re-login
- If network issue: Check WiFi/data connection

---

#### Issue: Real-time Updates Not Working

**Symptoms**:
- Changes don't appear without manual refresh
- Need to close and reopen screen to see changes

**Troubleshooting Steps**:
1. Check Firestore connection status
2. Verify StreamBuilder implementation in code
3. Check for errors in Flutter console
4. Verify internet connection is stable
5. Check Firebase quota limits

**Solution**:
- Restart app
- Check network connection
- Verify Firebase project status

---

#### Issue: Form Won't Submit

**Symptoms**:
- Add/Edit form doesn't save
- No success or error message

**Troubleshooting Steps**:
1. Check all required fields are filled
2. Verify quantity fields have numeric values
3. Check Firebase write permissions
4. Review console logs for validation errors
5. Check internet connection

**Solution**:
- Fill all required fields
- Enter valid data types
- Check Firestore security rules

---

#### Issue: Search Not Finding Items

**Symptoms**:
- Search returns no results
- Known items don't appear in search

**Troubleshooting Steps**:
1. Verify item name spelled correctly
2. Try searching by SAP code instead
3. Check if search is case-sensitive (shouldn't be)
4. Verify item actually exists in Firestore

**Solution**:
- Use different search terms
- Check spelling
- Verify item exists

---

#### Issue: App Crashes on Startup

**Symptoms**:
- App closes immediately after launch
- Black screen then crash

**Troubleshooting Steps**:
1. Check Flutter logs: `flutter logs`
2. Verify google-services.json exists
3. Check Firebase configuration
4. Clean and rebuild: `flutter clean && flutter pub get && flutter run`
5. Check Android minimum SDK version

**Solution**:
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

#### Issue: Build Failed

**Symptoms**:
- Error during `flutter run`
- Gradle build failures

**Troubleshooting Steps**:
1. Read error message carefully
2. Check internet connection (downloading dependencies)
3. Clean build cache
4. Update dependencies
5. Check Android SDK installation

**Solution**:
```powershell
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

### Useful Commands for Testing

#### View Live Logs
```powershell
flutter logs
```

#### Verbose Output
```powershell
flutter run -v
```

#### Check Flutter Environment
```powershell
flutter doctor -v
```

#### List Devices
```powershell
flutter devices
```

#### Clear App Data (Android)
```powershell
adb shell pm clear com.example.engineering_store
```

#### Restart ADB
```powershell
adb kill-server
adb start-server
```

#### Check Firestore Data
- Open Firebase Console: https://console.firebase.google.com
- Select project
- Go to Firestore Database
- Browse collections

---

## Appendix A: Test Data Setup

### Creating Test Users

#### Admin User
```
Email: admin@test.com
Password: admin123
Role: Admin (A)
```

#### Storekeeper User
```
Email: storekeeper@test.com
Password: store123
Role: Storekeeper (S)
```

#### Technician User
```
Email: tech@test.com
Password: tech123
Role: Technician (T)
```

### Creating Test Inventory Items

#### Item 1 - Good Stock
```
SAP Code: TEST001
Name: Test Bearing 6200
Internal Ref: TB-001
Description: Double row ball bearing
Safety Stock: 50
Replenish Qty: 100
Actual Quantity: 75
Rack Number: A
Rack Level: 3
```

#### Item 2 - Low Stock
```
SAP Code: TEST002
Name: Test Seal Ring
Internal Ref: TS-002
Description: Rubber seal ring
Safety Stock: 20
Replenish Qty: 50
Actual Quantity: 3
Rack Number: B
Rack Level: 1
```

#### Item 3 - Out of Stock
```
SAP Code: TEST003
Name: Test Bolt M12
Internal Ref: TBM-003
Description: Hex bolt M12x50
Safety Stock: 100
Replenish Qty: 200
Actual Quantity: 0
Rack Number: C
Rack Level: 2
```

---

## Appendix B: Quality Metrics

### Success Criteria

- **Pass Rate**: ≥ 95% of test cases pass
- **Critical Bugs**: 0 critical bugs in production
- **Performance**: All screens load within 2 seconds
- **User Satisfaction**: Positive user feedback

### Test Coverage Goals

- **Functional Coverage**: 100% of requirements
- **Screen Coverage**: 100% of screens tested
- **User Flow Coverage**: All major user flows tested
- **Edge Case Coverage**: Known edge cases tested

---

## Conclusion

This comprehensive testing guide covers all aspects of the Engineering Store application. Regular execution of these test cases ensures the application maintains high quality and reliability.

---

**Document Version**: 1.0  
**Last Updated**: February 4, 2026  
**Maintained by**: DevX Development Team  
**Next Review**: As needed or with major releases

---

*For questions or clarifications on testing procedures, contact the QA team or refer to the project documentation.*
