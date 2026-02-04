import 'package:flutter/material.dart';
import '../widgets/home_action.dart';

class UserGroup {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final Color color;

  UserGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.color,
  });
}

class UserGroupScreen extends StatelessWidget {
  const UserGroupScreen({super.key});

  static final userGroups = [
    UserGroup(
      id: 'S',
      name: 'Storekeeper',
      description: 'Manages inventory and stock levels',
      permissions: [
        'View Inventory',
        'Add/Edit Items',
        'Record Usage',
        'Receive Items',
        'Issue Items',
        'View Reports',
      ],
      color: Colors.green,
    ),
    UserGroup(
      id: 'T',
      name: 'Technician',
      description: 'Views inventory and records usage',
      permissions: [
        'View Inventory',
        'Record Usage',
        'Issue Items',
        'View Usage History',
      ],
      color: Colors.orange,
    ),
    UserGroup(
      id: 'A',
      name: 'Admin',
      description: 'Full system access and management',
      permissions: [
        'Manage Users',
        'Manage Locations',
        'View All Reports',
        'System Configuration',
        'View Inventory',
        'Add/Edit Items',
        'Record Usage',
      ],
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group_outlined, size: 24),
            const SizedBox(width: 8),
            const Text('User Group'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info Bar
              Container(
                width: double.infinity,
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
                        'User groups define roles and permissions in the system',
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
              const SizedBox(height: 24),
              // User Groups Grid
              ...userGroups.map((group) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${group.name} group selected'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon and name
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: group.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getGroupIcon(group.id),
                                      color: group.color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          group.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Divider
                              Divider(
                                color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                              ),
                              const SizedBox(height: 12),
                              // Permissions Label
                              Text(
                                'Permissions',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Permissions List
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: group.permissions.map((permission) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: group.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: group.color.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      permission,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: group.color,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              // Footer
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Maintain by PED',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGroupIcon(String groupId) {
    switch (groupId) {
      case 'S':
        return Icons.warehouse_outlined;
      case 'T':
        return Icons.engineering_outlined;
      case 'A':
        return Icons.security_outlined;
      default:
        return Icons.group_outlined;
    }
  }
}
