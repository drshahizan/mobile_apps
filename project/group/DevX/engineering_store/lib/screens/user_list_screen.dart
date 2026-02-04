import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _searchQuery = '';

  String _mapRoleName(String code) {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.people_outline, size: 24),
            const SizedBox(width: 8),
            const Text('User List'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [homeIconButton(context)],
      ),
      body: Column(
        children: [
          // Header Info Bar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View all registered users and their details',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users by email or name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users registered yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter users based on search query
                final allUsers = snapshot.data!.docs;
                final filteredUsers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final displayName =
                      (data['displayName'] ?? '').toString().toLowerCase();
                  return email.contains(_searchQuery) ||
                      displayName.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final userData =
                        userDoc.data() as Map<String, dynamic>;
                    final userId = userDoc.id;

                    return _buildUserCard(
                      context,
                      userId,
                      userData,
                      isDarkMode,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
    bool isDarkMode,
  ) {
    final email = userData['email'] ?? 'N/A';
    final displayName = userData['displayName'] ?? 'N/A';
    final userGroup = userData['userGroup'] ?? 'N/A';
    final createdAt = userData['createdAt'] as Timestamp?;
    final status = userData['isActive'] == true ? 'Active' : 'Inactive';
    final statusColor =
        userData['isActive'] == true ? Colors.green : Colors.grey;
    
    // Map userGroup to readable role name
    String roleName = userGroup;
    if (userGroup == 'S') {
      roleName = 'Storekeeper';
    } else if (userGroup == 'T') {
      roleName = 'Technician';
    } else if (userGroup == 'A') {
      roleName = 'Admin';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Details Row
          Row(
            children: [
              Expanded(
                child: _buildDetailChip(
                  context,
                  Icons.security,
                  'Role',
                  roleName,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailChip(
                  context,
                  Icons.calendar_today,
                  'Registered',
                  createdAt != null
                      ? DateFormat('dd MMM yyyy')
                          .format(createdAt.toDate())
                      : 'N/A',
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Role Management Buttons
          Row(
            children: [
              Expanded(
                child: _buildRoleButton(
                  context,
                  'Storekeeper',
                  'S',
                  userId,
                  userGroup,
                  Colors.blue,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleButton(
                  context,
                  'Technician',
                  'T',
                  userId,
                  userGroup,
                  Colors.orange,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleButton(
                  context,
                  'Admin',
                  'A',
                  userId,
                  userGroup,
                  Colors.green,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String label,
    String roleCode,
    String userId,
    String currentRole,
    Color color,
    bool isDarkMode,
  ) {
    final isActive = currentRole == roleCode;
    
    // Professional color schemes for each role
    final Map<String, List<Color>> roleGradients = {
      'S': [Color(0xFF4A90E2), Color(0xFF357ABD)], // Professional Blue
      'T': [Color(0xFFFF8C42), Color(0xFFE67E22)], // Professional Orange
      'A': [Color(0xFF10B981), Color(0xFF059669)], // Professional Green
    };
    
    return Container(
      decoration: isActive ? BoxDecoration(
        gradient: LinearGradient(
          colors: roleGradients[roleCode]!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: roleGradients[roleCode]![0].withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ) : null,
      child: ElevatedButton(
        onPressed: isActive ? null : () async {
          try {
            final authService = AuthService();
            final activityLoggingService = ActivityLoggingService();
            
            // Get old role for logging
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            final oldRoleCode = (userDoc.data()?['userGroup'] as String?) ?? 'N/A';
            final oldRoleName = _mapRoleName(oldRoleCode);
            final userEmail = (userDoc.data()?['email'] as String?) ?? 'Unknown';
            
            // Update role
            await authService.updateUserRole(userId, roleCode);
            
            // Log the role change
            await activityLoggingService.logUserRoleChange(
              targetUserId: userId,
              targetUserEmail: userEmail,
              oldRole: oldRoleName,
              newRole: label,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Role updated to $label'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.transparent : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          foregroundColor: isActive ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive ? Colors.transparent : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
              width: 1.5,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check_circle, size: 14, color: Colors.white),
              ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blue[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[200] : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
