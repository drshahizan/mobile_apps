import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for logging user activities and system events
/// Tracks screen access, inventory changes, user management, and more
class ActivityLoggingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log a user activity to Firestore
  /// 
  /// [action] - The type of action (e.g., 'SCREEN_ACCESS', 'EDIT_ITEM', 'ADD_ITEM')
  /// [screenName] - The name of the screen or feature
  /// [details] - Additional details about the action (optional)
  /// [itemId] - Related item ID if applicable (optional)
  /// [changes] - Map of before/after values for edits (optional)
  Future<void> logActivity({
    required String action,
    required String screenName,
    Map<String, dynamic>? details,
    String? itemId,
    Map<String, dynamic>? changes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user role from Firestore
      String userRole = 'Unknown';
      try {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userGroup = userDoc.data()?['userGroup'] ?? 'N/A';
          userRole = _mapRoleCode(userGroup);
        }
      } catch (e) {
        print('Error fetching user role: $e');
      }

      final logData = {
        'userId': user.uid,
        'userEmail': user.email ?? 'Unknown',
        'userRole': userRole,
        'action': action,
        'screenName': screenName,
        'timestamp': FieldValue.serverTimestamp(),
        'details': details ?? {},
        'itemId': itemId,
        'changes': changes,
      };

      await _db.collection('activity_logs').add(logData);
    } catch (e) {
      // Silent fail - don't break app if logging fails
      print('Activity logging error: $e');
    }
  }

  /// Log screen access
  Future<void> logScreenAccess(String screenName) async {
    await logActivity(
      action: 'SCREEN_ACCESS',
      screenName: screenName,
    );
  }

  /// Log item addition
  Future<void> logItemAdded({
    required String itemId,
    required String itemName,
    required Map<String, dynamic> itemData,
  }) async {
    await logActivity(
      action: 'ADD_ITEM',
      screenName: 'Inventory',
      itemId: itemId,
      details: {
        'itemName': itemName,
        'itemData': itemData,
      },
    );
  }

  /// Log item edit
  Future<void> logItemEdited({
    required String itemId,
    required String itemName,
    required Map<String, dynamic> changes,
  }) async {
    await logActivity(
      action: 'EDIT_ITEM',
      screenName: 'Inventory',
      itemId: itemId,
      details: {
        'itemName': itemName,
      },
      changes: changes,
    );
  }

  /// Log item deletion
  Future<void> logItemDeleted({
    required String itemId,
    required String itemName,
  }) async {
    await logActivity(
      action: 'DELETE_ITEM',
      screenName: 'Inventory',
      itemId: itemId,
      details: {
        'itemName': itemName,
      },
    );
  }

  /// Log receive item transaction
  Future<void> logReceiveItem({
    required String itemId,
    required String itemName,
    required int quantity,
    required String source,
    String? remarks,
  }) async {
    await logActivity(
      action: 'RECEIVE_ITEM',
      screenName: 'Receive Item',
      itemId: itemId,
      details: {
        'itemName': itemName,
        'quantity': quantity,
        'source': source,
        'remarks': remarks,
      },
    );
  }

  /// Log issue item transaction
  Future<void> logIssueItem({
    required String itemId,
    required String itemName,
    required int quantity,
    required String recipient,
    String? remarks,
  }) async {
    await logActivity(
      action: 'ISSUE_ITEM',
      screenName: 'Issue Item',
      itemId: itemId,
      details: {
        'itemName': itemName,
        'quantity': quantity,
        'recipient': recipient,
        'remarks': remarks,
      },
    );
  }

  /// Log usage record
  Future<void> logUsageRecord({
    required String itemId,
    required String itemName,
    required int quantity,
    String? remarks,
  }) async {
    await logActivity(
      action: 'RECORD_USAGE',
      screenName: 'Record Usage',
      itemId: itemId,
      details: {
        'itemName': itemName,
        'quantity': quantity,
        'remarks': remarks,
      },
    );
  }

  /// Log user role change
  Future<void> logUserRoleChange({
    required String targetUserId,
    required String targetUserEmail,
    required String oldRole,
    required String newRole,
  }) async {
    await logActivity(
      action: 'CHANGE_USER_ROLE',
      screenName: 'User Management',
      details: {
        'targetUserId': targetUserId,
        'targetUserEmail': targetUserEmail,
      },
      changes: {
        'role': {'old': oldRole, 'new': newRole},
      },
    );
  }

  /// Log location added
  Future<void> logLocationAdded({
    required String locationId,
    required String locationName,
    required Map<String, dynamic> locationData,
  }) async {
    await logActivity(
      action: 'ADD_LOCATION',
      screenName: 'Location Management',
      details: {
        'locationId': locationId,
        'locationName': locationName,
        'locationData': locationData,
      },
    );
  }

  /// Log location edited
  Future<void> logLocationEdited({
    required String locationId,
    required String locationName,
    required Map<String, dynamic> changes,
  }) async {
    await logActivity(
      action: 'EDIT_LOCATION',
      screenName: 'Location Management',
      details: {
        'locationId': locationId,
        'locationName': locationName,
      },
      changes: changes,
    );
  }

  /// Log location deleted
  Future<void> logLocationDeleted({
    required String locationId,
    required String locationName,
  }) async {
    await logActivity(
      action: 'DELETE_LOCATION',
      screenName: 'Location Management',
      details: {
        'locationId': locationId,
        'locationName': locationName,
      },
    );
  }

  /// Log user login
  Future<void> logUserLogin() async {
    await logActivity(
      action: 'USER_LOGIN',
      screenName: 'Authentication',
    );
  }

  /// Log user logout
  Future<void> logUserLogout() async {
    await logActivity(
      action: 'USER_LOGOUT',
      screenName: 'Authentication',
    );
  }

  /// Map role code to readable name
  String _mapRoleCode(String code) {
    switch (code) {
      case 'A':
        return 'Admin';
      case 'S':
        return 'Storekeeper';
      case 'T':
        return 'Technician';
      default:
        return code;
    }
  }

  /// Get activity logs stream with optional filters
  Stream<QuerySnapshot> getActivityLogsStream({
    String? filterAction,
    String? filterUser,
    int limit = 50,
  }) {
    Query query = _db
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (filterAction != null && filterAction != 'All') {
      query = query.where('action', isEqualTo: filterAction);
    }

    if (filterUser != null && filterUser.isNotEmpty) {
      query = query.where('userEmail', isEqualTo: filterUser);
    }

    return query.snapshots();
  }
}
