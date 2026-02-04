# Software Requirement Specification (SRS)

## Engineering Store - Inventory Management System

---

**Document Version**: 1.0  
**Date**: February 4, 2026  
**Project Name**: Engineering Store  
**Project Version**: 0.1.0+1  
**Prepared by**: DevX Development Team  
**Status**: Approved

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 4, 2026 | DevX Team | Initial SRS document |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [System Features](#3-system-features)
4. [External Interface Requirements](#4-external-interface-requirements)
5. [System Features Details](#5-system-features-details)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Other Requirements](#7-other-requirements)
8. [Appendix](#8-appendix)

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) document provides a complete description of all functions and specifications of the Engineering Store Inventory Management System. The document is intended for:
- Development team members
- Project stakeholders
- Quality assurance team
- System administrators
- End users

### 1.2 Document Conventions

- **Shall**: Indicates mandatory requirement
- **Should**: Indicates recommended requirement
- **May**: Indicates optional requirement
- **FR**: Functional Requirement
- **NFR**: Non-Functional Requirement

### 1.3 Intended Audience

- **Developers**: Implementation guidelines and technical specifications
- **Testers**: Test case development and validation criteria
- **Project Managers**: Project scope and progress tracking
- **Stakeholders**: System capabilities and business value
- **End Users**: System functionality and usage

### 1.4 Project Scope

The Engineering Store application is a mobile inventory management system designed to:
- Track engineering store inventory in real-time
- Manage item receiving and issuance transactions
- Provide complete audit trail of inventory movements
- Enable role-based access control
- Synchronize data across multiple devices
- Generate inventory reports and statistics

**In Scope**:
- Android mobile application
- Firebase backend integration
- Real-time data synchronization
- User authentication and authorization
- Inventory CRUD operations
- Transaction recording
- Audit trail and history
- Search and filter capabilities

**Out of Scope**:
- iOS application (future release)
- Web application
- Barcode/QR code scanning
- Push notifications
- Advanced analytics and reporting
- Multi-warehouse management
- Supplier management module
- Purchase order system

### 1.5 References

- IEEE 830-1998 - IEEE Recommended Practice for Software Requirements Specifications
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Documentation: https://docs.flutter.dev
- Material Design 3 Guidelines: https://m3.material.io

---

## 2. Overall Description

### 2.1 Product Perspective

The Engineering Store application is a standalone mobile application that operates on Android devices. It interfaces with:
- **Firebase Authentication**: User authentication and session management
- **Cloud Firestore**: Real-time database for inventory and transactions
- **Firebase Storage**: File storage for future enhancements (prepared)
- **Android OS**: Native Android application platform

**System Context Diagram**:
```
┌─────────────────────────────────────────┐
│         Android Mobile Device           │
│  ┌───────────────────────────────────┐  │
│  │   Engineering Store Application   │  │
│  │                                   │  │
│  │  ┌────────┐  ┌────────────────┐  │  │
│  │  │ Login  │  │   Dashboard    │  │  │
│  │  └────────┘  └────────────────┘  │  │
│  │  ┌─────────────────────────────┐ │  │
│  │  │   Inventory Management      │ │  │
│  │  └─────────────────────────────┘ │  │
│  │  ┌─────────────────────────────┐ │  │
│  │  │   Transaction Recording     │ │  │
│  │  └─────────────────────────────┘ │  │
│  └───────────────┬───────────────────┘  │
└───────────────────┼──────────────────────┘
                    │ HTTPS/WebSocket
         ┌──────────▼──────────┐
         │  Firebase Services  │
         │  ┌────────────────┐ │
         │  │ Authentication │ │
         │  ├────────────────┤ │
         │  │   Firestore    │ │
         │  ├────────────────┤ │
         │  │    Storage     │ │
         │  └────────────────┘ │
         └─────────────────────┘
```

### 2.2 Product Functions

**High-Level Functions**:
1. **User Management**: Registration, authentication, role assignment
2. **Inventory Management**: CRUD operations for inventory items
3. **Transaction Management**: Record receiving and issuing of items
4. **Reporting**: View transaction history and movement logs
5. **Real-time Synchronization**: Automatic data updates across devices
6. **Search & Filter**: Find items quickly using various criteria

### 2.3 User Classes and Characteristics

#### **Admin (A)**
- **Technical Expertise**: High
- **Frequency of Use**: Daily
- **Responsibilities**:
  - User management and approval
  - System configuration
  - All inventory operations
  - Report generation
- **Privileges**: Full system access

#### **Storekeeper (S)**
- **Technical Expertise**: Medium
- **Frequency of Use**: Daily
- **Responsibilities**:
  - Receive items from suppliers
  - Issue items to technicians
  - Update inventory counts
  - View reports
- **Privileges**: Inventory management, transactions

#### **Technician (T)**
- **Technical Expertise**: Low to Medium
- **Frequency of Use**: As needed
- **Responsibilities**:
  - View inventory availability
  - Request items
  - View personal transaction history
- **Privileges**: Read-only access to inventory

### 2.4 Operating Environment

**Hardware**:
- Android mobile device or tablet
- Minimum: 2GB RAM, dual-core processor
- Recommended: 4GB+ RAM, quad-core processor
- Screen size: 5" to 10"
- Storage: 100MB available space

**Software**:
- Android OS: Version 5.0 (API 21) or higher
- Target: Android 14 (API 34)
- Internet connection: Required for real-time sync
- Firebase services: Active account required

**Network**:
- Minimum: 3G mobile data or WiFi
- Recommended: 4G/5G or high-speed WiFi
- Bandwidth: Low (optimized for mobile)

### 2.5 Design and Implementation Constraints

**Technical Constraints**:
- Must use Flutter framework (version 3.35.6)
- Must use Firebase for backend services
- Must support Android only (initially)
- Must follow Material Design 3 guidelines
- Must use Dart programming language

**Regulatory Constraints**:
- Must comply with data privacy regulations
- Must secure user authentication
- Must maintain audit trail for compliance
- Must follow best practices for data security

**Business Constraints**:
- Development timeline: 2 months
- Budget: Limited (free Firebase tier)
- Team size: DevX Development Team
- No paid third-party services

### 2.6 Assumptions and Dependencies

**Assumptions**:
- Users have basic smartphone operation knowledge
- Internet connectivity is available during use
- Firebase services remain available and stable
- Android devices meet minimum requirements
- Users have valid email addresses for registration

**Dependencies**:
- Firebase services availability
- Flutter framework updates
- Android OS compatibility
- Google Play Services
- Package dependencies maintained

---

## 3. System Features

### 3.1 Feature List Overview

| ID | Feature | Priority | Status |
|----|---------|----------|--------|
| F1 | User Authentication | High | ✅ Complete |
| F2 | Dashboard & Statistics | High | ✅ Complete |
| F3 | Inventory Management | High | ✅ Complete |
| F4 | Transaction Recording | High | ✅ Complete |
| F5 | History & Audit Trail | High | ✅ Complete |
| F6 | Search & Filter | Medium | ✅ Complete |
| F7 | User Management | Medium | ✅ Complete |
| F8 | Location Management | Medium | ✅ Complete |
| F9 | Real-time Synchronization | High | ✅ Complete |
| F10 | Role-Based Access Control | High | ✅ Complete |

---

## 4. External Interface Requirements

### 4.1 User Interfaces

#### 4.1.1 Login Screen
**Description**: Initial screen for user authentication
**Elements**:
- Email input field
- Password input field (masked)
- "Sign In" button
- "Forgot Password?" link
- "Don't have an account? Register" link
- Company logo
- Error message display area

**Behavior**:
- Email validation on input
- Password minimum length check
- Show/hide password toggle
- Loading indicator during authentication
- Navigate to home on successful login

#### 4.1.2 Home Screen (Dashboard)
**Description**: Main dashboard after successful login
**Elements**:
- Welcome message with username
- Profile menu icon
- Dashboard statistics cards:
  - Total Items (clickable)
  - Low Stock count
  - Out of Stock count
- Quick Action buttons:
  - Receive Item
  - Issue Item
- Navigation menu sections:
  - Inventory Holding
  - Inventory Consumption
  - System Management

**Behavior**:
- Real-time stat updates
- Navigate to inventory on card click
- Open respective screens on button clicks
- Show user profile menu on icon click

#### 4.1.3 Inventory List Screen
**Description**: Display all inventory items in real-time
**Elements**:
- Search bar at top
- Floating action button (+) for adding items
- List of item cards showing:
  - SAP Code
  - Item Name
  - Current Stock
  - Stock Status badge (color-coded)
- Empty state message if no items
- Loading indicator

**Behavior**:
- Real-time updates via StreamBuilder
- Filter items as user types in search
- Long-press on item to delete
- Tap item to view details
- Checkbox selection for bulk delete

#### 4.1.4 Add/Edit Item Screen
**Description**: Form to add or edit inventory items
**Elements**:
- Form fields:
  - SAP Number (required)
  - Item Name (required)
  - Internal Reference (required)
  - Description
  - Safety Stock Level
  - Replenishment Quantity
  - Actual Quantity (required)
  - Rack Number (required)
  - Rack Level (required)
- Submit button ("ADD ITEM" or "UPDATE ITEM")
- Cancel/Back button

**Behavior**:
- Validate required fields
- Show error messages below fields
- Auto-generate location string
- Save to Firestore on submit
- Navigate back to list after save

#### 4.1.5 Receive Item Screen
**Description**: Record supplier deliveries
**Elements**:
- SAP Number dropdown
- Item Name (auto-filled)
- Quantity Received input
- Supplier Name input
- Remarks textarea
- "CONFIRM" button

**Behavior**:
- Load items for dropdown
- Auto-fill item name on SAP selection
- Validate quantity (positive number)
- Save to receivings and movement_logs
- Update inventory stock
- Show success message

#### 4.1.6 Issue Item Screen
**Description**: Record item issuance to technicians
**Elements**:
- SAP Number dropdown
- Item Name (auto-filled)
- Quantity Needed input
- Usage Location input
- Technician Name input
- Remarks textarea
- "CONFIRM" button

**Behavior**:
- Load items with available stock
- Validate stock availability
- Prevent over-issuing
- Save to issuance and movement_logs
- Update inventory stock
- Show success message

#### 4.1.7 Usage History Screen
**Description**: View combined transaction history
**Elements**:
- Filter chips (All, Receiving, Issuance)
- Transaction list showing:
  - Transaction type badge
  - Item name
  - Quantity
  - Date/time
  - User/supplier/technician info

**Behavior**:
- Real-time updates using RxDart
- Filter by transaction type
- Sort chronologically (newest first)
- Display combined data from two collections

### 4.2 Hardware Interfaces

**Touchscreen**:
- Multi-touch gestures
- Tap, long-press, swipe
- Virtual keyboard input

**Camera** (Future):
- Barcode/QR code scanning
- Document capture

**Storage**:
- Local app data storage
- Cache management

### 4.3 Software Interfaces

#### 4.3.1 Firebase Authentication
- **Type**: Cloud service
- **Purpose**: User authentication and session management
- **Interface**: Firebase Auth SDK for Flutter
- **Data**: Email, password, user ID, auth tokens

#### 4.3.2 Cloud Firestore
- **Type**: NoSQL cloud database
- **Purpose**: Data storage and real-time synchronization
- **Interface**: Firestore SDK for Flutter
- **Collections**: inventory, users, receivings, issuance, movement_logs
- **Operations**: Read, write, update, delete, real-time listeners

#### 4.3.3 Firebase Storage
- **Type**: Cloud storage service
- **Purpose**: File and image storage (prepared for future use)
- **Interface**: Firebase Storage SDK for Flutter
- **Data**: Images, PDFs, documents

#### 4.3.4 Android OS
- **Type**: Mobile operating system
- **Purpose**: Application platform
- **Interface**: Flutter platform channels
- **Features**: Permissions, notifications, file system

### 4.4 Communication Interfaces

**Protocol**: HTTPS, WebSocket (for real-time)
**Format**: JSON
**Security**: TLS 1.2+
**Authentication**: JWT tokens (Firebase managed)

**API Endpoints** (Firebase REST - for reference):
```
POST /accounts:signInWithPassword
GET /projects/{project}/databases/(default)/documents/{collection}
POST /projects/{project}/databases/(default)/documents/{collection}
PUT /projects/{project}/databases/(default)/documents/{collection}/{doc}
DELETE /projects/{project}/databases/(default)/documents/{collection}/{doc}
```

---

## 5. System Features Details

### 5.1 User Authentication

**ID**: FR-AUTH  
**Priority**: High  
**Status**: Complete

#### 5.1.1 Description
Users shall be able to authenticate using email and password. The system shall maintain user sessions and provide secure access to the application.

#### 5.1.2 Functional Requirements

**FR-AUTH-001**: The system shall provide a login screen with email and password fields.
- **Input**: Email address, password
- **Processing**: Validate credentials with Firebase Auth
- **Output**: Authentication token, user profile
- **Error**: Display error message for invalid credentials

**FR-AUTH-002**: The system shall validate email format before submission.
- **Validation**: Standard email regex pattern
- **Error Message**: "Please enter a valid email address"

**FR-AUTH-003**: The system shall enforce minimum password requirements.
- **Minimum Length**: 6 characters
- **Error Message**: "Password must be at least 6 characters"

**FR-AUTH-004**: The system shall provide password reset functionality.
- **Input**: Email address
- **Processing**: Send reset email via Firebase
- **Output**: Confirmation message
- **Error**: Display error for non-existent email

**FR-AUTH-005**: The system shall maintain user session across app restarts.
- **Mechanism**: Firebase Auth persistence
- **Duration**: Until explicit logout

**FR-AUTH-006**: The system shall provide logout functionality.
- **Action**: Sign out from Firebase Auth
- **Effect**: Clear session, navigate to login screen

#### 5.1.3 User Stories

**US-AUTH-001**: As a user, I want to login with my email and password so that I can access the application.
- **Acceptance Criteria**:
  - Login screen is displayed on app launch if not authenticated
  - Email and password fields are present
  - Successful login navigates to home screen
  - Error messages display for failed login

**US-AUTH-002**: As a user, I want to reset my password if I forget it so that I can regain access.
- **Acceptance Criteria**:
  - Forgot password link is visible on login screen
  - Reset email is sent upon entering valid email
  - Confirmation message is displayed

---

### 5.2 Dashboard & Statistics

**ID**: FR-DASH  
**Priority**: High  
**Status**: Complete

#### 5.2.1 Description
The system shall provide a dashboard showing real-time inventory statistics and quick access to common functions.

#### 5.2.2 Functional Requirements

**FR-DASH-001**: The system shall display total item count.
- **Source**: Count of documents in inventory collection
- **Update**: Real-time via StreamBuilder
- **Display**: Numerical value with label

**FR-DASH-002**: The system shall display low stock count.
- **Definition**: Items with 1-5 units
- **Calculation**: Filter inventory where currentStock >= 1 AND currentStock <= 5
- **Display**: Numerical value with warning indicator

**FR-DASH-003**: The system shall display out of stock count.
- **Definition**: Items with 0 units
- **Calculation**: Filter inventory where currentStock == 0
- **Display**: Numerical value with critical indicator

**FR-DASH-004**: Statistics cards shall be clickable and navigate to relevant screens.
- **Total Items Card**: Navigate to inventory list
- **Low Stock Card**: Navigate to inventory list (future: pre-filtered)
- **Out of Stock Card**: Navigate to inventory list (future: pre-filtered)

**FR-DASH-005**: The system shall provide quick action buttons for common tasks.
- **Receive Item**: Navigate to receive item screen
- **Issue Item**: Navigate to issue item screen

#### 5.2.3 User Stories

**US-DASH-001**: As a storekeeper, I want to see real-time inventory statistics on the dashboard so that I can quickly assess stock levels.
- **Acceptance Criteria**:
  - Dashboard displays total items count
  - Dashboard displays low stock count (1-5 units)
  - Dashboard displays out of stock count (0 units)
  - Statistics update automatically when inventory changes

**US-DASH-002**: As a storekeeper, I want quick access buttons on the dashboard so that I can perform common tasks quickly.
- **Acceptance Criteria**:
  - "Receive Item" button is visible
  - "Issue Item" button is visible
  - Buttons navigate to respective screens

---

### 5.3 Inventory Management

**ID**: FR-INV  
**Priority**: High  
**Status**: Complete

#### 5.3.1 Description
The system shall allow users to create, read, update, and delete inventory items with real-time synchronization.

#### 5.3.2 Functional Requirements

**FR-INV-001**: The system shall display a list of all inventory items in real-time.
- **Source**: Firestore inventory collection
- **Mechanism**: StreamBuilder with snapshots()
- **Display**: Scrollable list of item cards
- **Sorting**: Default by lastUpdated (newest first)

**FR-INV-002**: The system shall allow users to add new inventory items.
- **Required Fields**:
  - SAP Number (unique)
  - Item Name
  - Internal Reference
  - Actual Quantity
  - Rack Number
  - Rack Level
- **Optional Fields**:
  - Description
  - Safety Stock Level
  - Replenishment Quantity
- **Validation**:
  - All required fields must be filled
  - SAP Number must be unique
  - Quantities must be non-negative numbers
- **Action**: Save to Firestore inventory collection
- **Effect**: Item appears in list immediately

**FR-INV-003**: The system shall allow users to edit existing inventory items.
- **Access**: Via item detail screen or edit button
- **Editable Fields**: All fields can be modified
- **Validation**: Same as add item
- **Action**: Update Firestore document
- **Effect**: Changes reflect immediately in list

**FR-INV-004**: The system shall allow users to delete inventory items.
- **Methods**:
  - Single delete: Long-press on item
  - Bulk delete: Checkbox selection
- **Confirmation**: Dialog with "Are you sure?" message
- **Action**: Delete from Firestore
- **Effect**: Item removed from list immediately

**FR-INV-005**: The system shall display detailed information for each item.
- **Access**: Tap on item in list
- **Information Displayed**:
  - SAP Code
  - Item Name
  - Internal Reference
  - Description
  - Current Stock
  - Safety Stock Level
  - Replenishment Quantity
  - Rack Number
  - Rack Level
  - Full Location
  - Last Updated timestamp
  - Stock Status badge
- **Actions Available**:
  - Edit Item button
  - Adjust Stock button
  - Back navigation

**FR-INV-006**: The system shall calculate and display stock status for each item.
- **Status Types**:
  - **OUT**: currentStock == 0 (Red badge)
  - **LOW!**: currentStock >= 1 AND <= 5 (Orange badge)
  - **GOOD**: currentStock > 5 (Green badge)
- **Display**: Color-coded badge on item cards and detail screen

**FR-INV-007**: The system shall generate location string automatically.
- **Format**: "Rack {rackNumber}, Level {rackLevel}"
- **Example**: "Rack A, Level 3"
- **Trigger**: When rack number or level is entered

#### 5.3.3 User Stories

**US-INV-001**: As a storekeeper, I want to add new items to inventory so that I can track all store items.
- **Acceptance Criteria**:
  - Add item button is accessible
  - Form includes all required fields
  - Validation errors are displayed
  - Item appears in list after successful save
  - Success message is displayed

**US-INV-002**: As a storekeeper, I want to view detailed information about an item so that I can check all its properties.
- **Acceptance Criteria**:
  - Tapping item opens detail screen
  - All item information is displayed
  - Stock status is color-coded
  - Navigation back to list is available

**US-INV-003**: As a storekeeper, I want to delete items so that I can remove discontinued or obsolete items.
- **Acceptance Criteria**:
  - Long-press shows delete option
  - Confirmation dialog is displayed
  - Item is removed after confirmation
  - List updates immediately

---

### 5.4 Transaction Recording

**ID**: FR-TRANS  
**Priority**: High  
**Status**: Complete

#### 5.4.1 Description
The system shall allow users to record receiving and issuing transactions with automatic stock updates and audit trail creation.

#### 5.4.2 Functional Requirements - Receive Items

**FR-TRANS-001**: The system shall allow users to record item receipts.
- **Input Fields**:
  - SAP Number (dropdown from inventory)
  - Item Name (auto-filled)
  - Quantity Received (positive number)
  - Supplier Name
  - Remarks (optional)
- **Validation**:
  - SAP Number must be selected
  - Quantity must be positive number
  - Supplier name is required
- **Actions**:
  1. Save to receivings collection
  2. Save to movement_logs collection (type: Inbound)
  3. Update inventory currentStock (+quantity)
  4. Record timestamp
  5. Record user ID
- **Output**:
  - Success message
  - Form reset for next entry

**FR-TRANS-002**: Stock shall increase automatically when items are received.
- **Calculation**: currentStock = currentStock + quantityReceived
- **Execution**: As part of receive transaction
- **Synchronization**: Real-time update in inventory list

#### 5.4.3 Functional Requirements - Issue Items

**FR-TRANS-003**: The system shall allow users to record item issuance.
- **Input Fields**:
  - SAP Number (dropdown from inventory)
  - Item Name (auto-filled)
  - Quantity Needed (positive number)
  - Usage Location
  - Technician Name
  - Remarks (optional)
- **Validation**:
  - SAP Number must be selected
  - Quantity must be positive number
  - Quantity must not exceed available stock
  - Usage location is required
  - Technician name is required
- **Actions**:
  1. Validate stock availability
  2. Save to issuance collection
  3. Save to movement_logs collection (type: Outbound)
  4. Update inventory currentStock (-quantity)
  5. Record timestamp
  6. Record user ID
- **Output**:
  - Success message
  - Form reset for next entry
  - Error message if insufficient stock

**FR-TRANS-004**: Stock shall decrease automatically when items are issued.
- **Calculation**: currentStock = currentStock - quantityIssued
- **Validation**: Prevent if currentStock < quantityIssued
- **Execution**: As part of issue transaction
- **Synchronization**: Real-time update in inventory list

**FR-TRANS-005**: The system shall prevent over-issuing of items.
- **Check**: Before saving transaction
- **Condition**: quantityIssued <= currentStock
- **Error Message**: "Insufficient stock. Available: {currentStock}"
- **Action**: Prevent transaction, keep form open for correction

#### 5.4.4 User Stories

**US-TRANS-001**: As a storekeeper, I want to record item receipts so that inventory reflects received goods.
- **Acceptance Criteria**:
  - Receive item screen is accessible
  - Can select item from dropdown
  - Can enter quantity and supplier
  - Stock increases after save
  - Transaction appears in history

**US-TRANS-002**: As a storekeeper, I want to issue items to technicians so that I can track item usage.
- **Acceptance Criteria**:
  - Issue item screen is accessible
  - Can select item with available stock
  - System prevents over-issuing
  - Stock decreases after save
  - Transaction appears in history

---

### 5.5 Search & Filter

**ID**: FR-SEARCH  
**Priority**: Medium  
**Status**: Complete

#### 5.5.1 Description
The system shall provide search and filter capabilities to quickly find inventory items.

#### 5.5.2 Functional Requirements

**FR-SEARCH-001**: The system shall provide a search bar on inventory list.
- **Location**: Top of inventory list screen
- **Placeholder**: "Search by SAP, name, or description"
- **Behavior**: Filter list as user types

**FR-SEARCH-002**: The system shall filter items in real-time as user types.
- **Search Fields**: SAP code, item name, description
- **Matching**: Case-insensitive substring matching
- **Display**: Show only matching items
- **Performance**: Client-side filtering (fast)

**FR-SEARCH-003**: The system shall support clearing search.
- **Method**: Clear button (X) in search bar
- **Effect**: Show all items again

#### 5.5.3 User Stories

**US-SEARCH-001**: As a user, I want to search for items by SAP code or name so that I can find items quickly.
- **Acceptance Criteria**:
  - Search bar is visible on inventory list
  - Typing filters items in real-time
  - Search is case-insensitive
  - Can clear search to show all items

---

## 6. Non-Functional Requirements

### 6.1 Performance Requirements

**NFR-PERF-001**: Application Launch
- **Requirement**: App shall launch within 2 seconds on modern devices
- **Measurement**: Time from icon tap to login screen display
- **Environment**: Device with 4GB RAM, quad-core processor

**NFR-PERF-002**: Screen Navigation
- **Requirement**: Screen transitions shall complete within 300ms
- **Measurement**: Time from button tap to next screen render
- **Exception**: Network-dependent screens may take longer

**NFR-PERF-003**: Data Load Time
- **Requirement**: Inventory list shall load within 1 second for up to 1000 items
- **Measurement**: Time from screen open to data display
- **Dependency**: Network speed and Firestore performance

**NFR-PERF-004**: Search Response
- **Requirement**: Search results shall appear instantly (< 100ms)
- **Measurement**: Time from keystroke to filtered results
- **Implementation**: Client-side filtering

**NFR-PERF-005**: Real-time Updates
- **Requirement**: Changes shall propagate to all screens within 2 seconds
- **Measurement**: Time from save to display on other devices
- **Dependency**: Firebase real-time synchronization

### 6.2 Security Requirements

**NFR-SEC-001**: Authentication
- **Requirement**: All users shall be authenticated before accessing app features
- **Implementation**: Firebase Authentication with email/password
- **Enforcement**: Auth gate in app entry point

**NFR-SEC-002**: Password Security
- **Requirement**: Passwords shall be securely hashed and stored
- **Implementation**: Firebase Auth handles password encryption
- **Standard**: Industry-standard bcrypt or similar

**NFR-SEC-003**: Session Management
- **Requirement**: User sessions shall be securely maintained
- **Implementation**: JWT tokens via Firebase Auth
- **Expiry**: Configurable, default 1 hour with auto-refresh

**NFR-SEC-004**: Data Access Control
- **Requirement**: Users shall only access data they have permission for
- **Implementation**: Firestore security rules based on user role
- **Verification**: Rules tested in Firebase Console

**NFR-SEC-005**: Secure Communication
- **Requirement**: All data transmission shall be encrypted
- **Implementation**: HTTPS/TLS for all Firebase communication
- **Standard**: TLS 1.2 or higher

**NFR-SEC-006**: Input Validation
- **Requirement**: All user input shall be validated before processing
- **Implementation**: Client-side validation + Firestore security rules
- **Protection**: Against XSS, SQL injection (NoSQL), invalid data

### 6.3 Usability Requirements

**NFR-USE-001**: User Interface
- **Requirement**: UI shall follow Material Design 3 guidelines
- **Compliance**: Android platform conventions
- **Consistency**: Consistent styling across all screens

**NFR-USE-002**: Navigation
- **Requirement**: Users shall navigate between screens intuitively
- **Implementation**: Standard Android navigation patterns
- **Features**: Back button support, clear navigation hierarchy

**NFR-USE-003**: Error Messages
- **Requirement**: Error messages shall be user-friendly and actionable
- **Format**: Plain language, clear explanation, suggested action
- **Example**: "Unable to save item. Please check your internet connection."

**NFR-USE-004**: Loading Indicators
- **Requirement**: Loading states shall be clearly indicated
- **Implementation**: Progress indicators, skeleton screens
- **Duration**: Show for operations taking > 500ms

**NFR-USE-005**: Touch Targets
- **Requirement**: Touch targets shall be at least 48x48 dp
- **Standard**: Material Design accessibility guidelines
- **Application**: All buttons, links, interactive elements

**NFR-USE-006**: Feedback
- **Requirement**: User actions shall receive immediate feedback
- **Implementation**: Snackbars, toasts, animations
- **Timing**: Within 100ms of action

### 6.4 Reliability Requirements

**NFR-REL-001**: Availability
- **Requirement**: System shall be available 99.5% of time (excluding maintenance)
- **Dependency**: Firebase service level agreement
- **Measurement**: Monthly uptime tracking

**NFR-REL-002**: Data Integrity
- **Requirement**: Data shall remain consistent across all operations
- **Implementation**: Firestore transactions, atomic operations
- **Verification**: No data loss or corruption

**NFR-REL-003**: Error Recovery
- **Requirement**: System shall recover gracefully from errors
- **Implementation**: Try-catch blocks, error boundaries
- **Behavior**: Display error, allow retry, maintain app stability

**NFR-REL-004**: Data Backup
- **Requirement**: Data shall be backed up automatically
- **Implementation**: Firebase automatic backups
- **Frequency**: Continuous (real-time replication)

### 6.5 Maintainability Requirements

**NFR-MAIN-001**: Code Quality
- **Requirement**: Code shall follow Flutter and Dart best practices
- **Tools**: Flutter lints, dart analyzer
- **Enforcement**: CI/CD checks (future)

**NFR-MAIN-002**: Documentation
- **Requirement**: Code shall be documented with inline comments
- **Standard**: DartDoc format
- **Coverage**: All public classes and methods

**NFR-MAIN-003**: Modularity
- **Requirement**: Code shall be organized in logical modules
- **Structure**: Screens, services, widgets separation
- **Benefit**: Easy maintenance and testing

**NFR-MAIN-004**: Version Control
- **Requirement**: All code shall be version controlled
- **Tool**: Git
- **Practice**: Meaningful commit messages, branching strategy

### 6.6 Scalability Requirements

**NFR-SCAL-001**: User Capacity
- **Requirement**: System shall support up to 100 concurrent users
- **Limitation**: Firebase Spark plan limits
- **Upgrade Path**: Blaze plan for more users

**NFR-SCAL-002**: Data Volume
- **Requirement**: System shall handle up to 10,000 inventory items
- **Performance**: Maintain response times with full dataset
- **Implementation**: Efficient queries, pagination (future)

**NFR-SCAL-003**: Transaction Volume
- **Requirement**: System shall handle 1,000 transactions per day
- **Limitation**: Firebase free tier quotas
- **Monitoring**: Usage tracking in Firebase Console

### 6.7 Compatibility Requirements

**NFR-COMP-001**: Android Versions
- **Minimum**: Android 5.0 (API 21)
- **Target**: Android 14 (API 34)
- **Testing**: Test on multiple Android versions

**NFR-COMP-002**: Screen Sizes
- **Requirement**: App shall be responsive across device sizes
- **Range**: 5" phones to 10" tablets
- **Implementation**: Flexible layouts, adaptive UI

**NFR-COMP-003**: Device Manufacturers
- **Requirement**: App shall work on all major Android manufacturers
- **Brands**: Samsung, Google, Xiaomi, OnePlus, etc.
- **Testing**: Test on multiple device models

---

## 7. Other Requirements

### 7.1 Legal Requirements

**Data Privacy**:
- Comply with applicable data protection regulations
- User data stored securely in Firebase
- No sharing of user data with third parties
- User can request data deletion

**Terms of Service**:
- Users must accept terms before using app
- Terms include acceptable use policy
- Right to modify terms with notice

**Intellectual Property**:
- All code and assets owned by organization
- Open-source libraries used under their licenses
- Attribution for third-party resources

### 7.2 Operational Requirements

**Installation**:
- APK installation on Android devices
- Future: Distribution via Google Play Store
- Installation size: < 50MB

**Updates**:
- Over-the-air updates via app stores (future)
- Manual APK updates (current)
- Backward compatibility maintained

**Support**:
- User manual provided
- In-app help (future enhancement)
- Technical support contact information

### 7.3 Database Requirements

**Firestore Collections**:

1. **inventory**: ~10,000 documents max
   - Size per document: ~2KB
   - Total: ~20MB
   - Indexes: sapCode, name, lastUpdated

2. **users**: ~100 documents max
   - Size per document: ~1KB
   - Total: ~100KB

3. **receivings**: ~1,000 documents/month
   - Size per document: ~1KB
   - Retention: 12 months
   - Total: ~12MB/year

4. **issuance**: ~1,000 documents/month
   - Size per document: ~1KB
   - Retention: 12 months
   - Total: ~12MB/year

5. **movement_logs**: ~2,000 documents/month
   - Size per document: ~1KB
   - Retention: 12 months
   - Total: ~24MB/year

**Total Storage Estimate**: ~70MB (well within free tier)

---

## 8. Appendix

### 8.1 Glossary

| Term | Definition |
|------|------------|
| Admin | User with full system access and administrative privileges |
| Firebase | Google's mobile and web application development platform |
| Firestore | NoSQL cloud database from Firebase |
| Flutter | Google's UI toolkit for building natively compiled applications |
| Inventory | Collection of items tracked in the system |
| Issuance | Process of issuing items to technicians for use |
| Movement Log | Audit trail record of inventory movements |
| Receiving | Process of receiving items from suppliers |
| SAP Code | Unique identifier for inventory items |
| Storekeeper | User responsible for inventory management |
| StreamBuilder | Flutter widget that builds based on asynchronous data stream |
| Technician | User who requests and receives items |
| Transaction | Any receiving or issuance operation |

### 8.2 Acronyms

| Acronym | Full Form |
|---------|-----------|
| API | Application Programming Interface |
| CRUD | Create, Read, Update, Delete |
| FR | Functional Requirement |
| HTTPS | Hypertext Transfer Protocol Secure |
| JWT | JSON Web Token |
| NFR | Non-Functional Requirement |
| NoSQL | Not Only SQL (database type) |
| REST | Representational State Transfer |
| SAP | Systems, Applications & Products (code type) |
| SDK | Software Development Kit |
| SRS | Software Requirements Specification |
| TLS | Transport Layer Security |
| UI | User Interface |
| UX | User Experience |

### 8.3 Use Case Diagram

```
┌─────────────────────────────────────────────────┐
│         Engineering Store System                │
│                                                 │
│  ┌──────────────┐                              │
│  │   Login      │◄─────────────────┐           │
│  └──────────────┘                   │           │
│         │                            │           │
│  ┌──────▼──────────┐         ┌──────┴──────┐  │
│  │  View Dashboard │         │    Admin    │  │
│  └──────┬──────────┘         └──────┬──────┘  │
│         │                            │           │
│  ┌──────▼──────────┐                │           │
│  │ Manage Inventory│◄───────────────┤           │
│  │ - Add Item      │                │           │
│  │ - Edit Item     │                │           │
│  │ - Delete Item   │                │           │
│  │ - Search Item   │                │           │
│  └──────┬──────────┘                │           │
│         │                            │           │
│  ┌──────▼──────────┐         ┌──────┴──────┐  │
│  │ Record Trans.   │◄────────┤ Storekeeper │  │
│  │ - Receive Items │         └──────┬──────┘  │
│  │ - Issue Items   │                │           │
│  └──────┬──────────┘                │           │
│         │                            │           │
│  ┌──────▼──────────┐                │           │
│  │ View History    │◄───────────────┤           │
│  │ - Usage History │                │           │
│  │ - Movement Logs │                │           │
│  └─────────────────┘                │           │
│         │                            │           │
│  ┌──────▼──────────┐         ┌──────┴──────┐  │
│  │ View Inventory  │◄────────┤ Technician  │  │
│  │ (Read Only)     │         └─────────────┘  │
│  └─────────────────┘                           │
└─────────────────────────────────────────────────┘
```

### 8.4 Data Flow Diagram (Level 0)

```
┌───────────────┐
│  Storekeeper  │
└───────┬───────┘
        │
        │ Login, Manage Items, Record Transactions
        ▼
┌──────────────────────────────────────────────────┐
│                                                  │
│         Engineering Store System                │
│                                                  │
│  ┌────────────┐  ┌──────────────┐              │
│  │   Auth     │  │  Inventory   │              │
│  │  Service   │  │  Management  │              │
│  └────────────┘  └──────────────┘              │
│                                                  │
│  ┌────────────┐  ┌──────────────┐              │
│  │Transaction │  │   Reporting  │              │
│  │ Recording  │  │   & History  │              │
│  └────────────┘  └──────────────┘              │
│                                                  │
└──────────────────┬───────────────────────────────┘
                   │
                   │ Data Storage & Retrieval
                   ▼
        ┌──────────────────────┐
        │  Firebase Backend    │
        │  - Authentication    │
        │  - Firestore DB      │
        │  - Storage           │
        └──────────────────────┘
```

### 8.5 Entity Relationship Diagram

```
┌─────────────┐
│    users    │
├─────────────┤
│ uid (PK)    │
│ email       │
│ displayName │
│ userGroup   │
│ isActive    │
│ createdAt   │
│ lastLogin   │
└──────┬──────┘
       │
       │ 1
       │
       │ N
       │
┌──────▼──────────┐       ┌─────────────────┐
│   inventory     │       │   receivings    │
├─────────────────┤       ├─────────────────┤
│ docId (PK)      │       │ docId (PK)      │
│ sapCode         │◄──────┤ sapCode (FK)    │
│ name            │       │ itemName        │
│ internalRef     │       │ quantityReceived│
│ description     │       │ supplier        │
│ currentStock    │       │ remarks         │
│ maxStock        │       │ timestamp       │
│ replenishQty    │       │ date            │
│ rackNumber      │       │ status          │
│ rackLevel       │       │ userId (FK)     │
│ location        │       └─────────────────┘
│ lastUpdated     │
│ recentActivity  │       ┌─────────────────┐
└─────────┬───────┘       │   issuance      │
          │               ├─────────────────┤
          │               │ docId (PK)      │
          └───────────────┤ sapCode (FK)    │
                          │ itemName        │
                          │ quantityIssued  │
                          │ usageLocation   │
                          │ technicianName  │
                          │ remarks         │
                          │ timestamp       │
                          │ date            │
                          │ status          │
                          │ userId (FK)     │
                          └─────────────────┘
                                  │
                                  │
                          ┌───────▼─────────┐
                          │ movement_logs   │
                          ├─────────────────┤
                          │ docId (PK)      │
                          │ type            │
                          │ sapCode         │
                          │ itemName        │
                          │ quantity        │
                          │ source          │
                          │ remarks         │
                          │ timestamp       │
                          │ date            │
                          │ status          │
                          │ movementType    │
                          │ userId (FK)     │
                          └─────────────────┘
```

### 8.6 Screen Flow Diagram

```
Login Screen
     │
     │ [Success]
     ▼
Home Screen (Dashboard)
     ├───► Inventory Holding
     │     ├───► Inventory List
     │     │     ├───► Add Item
     │     │     ├───► Edit Item
     │     │     └───► Item Detail
     │     │
     ├───► Inventory Consumption
     │     ├───► Record Usage
     │     │     ├───► Receive Item
     │     │     └───► Issue Item
     │     └───► Usage History
     │
     └───► System Management
           ├───► Movement Logs
           └───► Master Data
                 ├───► User Management
                 └───► Location Management
```

### 8.7 Requirements Traceability Matrix

| Requirement ID | Feature | Priority | Status | Test Case |
|----------------|---------|----------|--------|-----------|
| FR-AUTH-001 | Login Screen | High | ✅ | TC-AUTH-001 |
| FR-AUTH-004 | Password Reset | High | ✅ | TC-AUTH-002 |
| FR-DASH-001 | Dashboard Stats | High | ✅ | TC-DASH-001 |
| FR-INV-001 | Inventory List | High | ✅ | TC-INV-001 |
| FR-INV-002 | Add Item | High | ✅ | TC-INV-002 |
| FR-INV-003 | Edit Item | High | ✅ | TC-INV-003 |
| FR-INV-004 | Delete Item | Medium | ✅ | TC-INV-004 |
| FR-TRANS-001 | Receive Items | High | ✅ | TC-TRANS-001 |
| FR-TRANS-003 | Issue Items | High | ✅ | TC-TRANS-002 |
| FR-SEARCH-001 | Search Bar | Medium | ✅ | TC-SEARCH-001 |

---

## Approval

### Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Manager | | | Feb 4, 2026 |
| Lead Developer | DevX Team | | Feb 4, 2026 |
| Quality Assurance | | | Feb 4, 2026 |
| Stakeholder | | | Feb 4, 2026 |

---

**Document Status**: ✅ **APPROVED**  
**Version**: 1.0  
**Last Updated**: February 4, 2026  
**Next Review**: As needed for changes

---

*This SRS document serves as the authoritative source for all system requirements and specifications for the Engineering Store Inventory Management System.*
