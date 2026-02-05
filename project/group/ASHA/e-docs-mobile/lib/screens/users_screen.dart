import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  final AuthService authService;

  const UsersScreen({super.key, required this.authService});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await widget.authService.apiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "${user.username}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await widget.authService.apiService.deleteUser(user.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddUserScreen(authService: widget.authService),
            ),
          );
          if (result == true) {
            _loadUsers();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isCurrentUser = user.id == widget.authService.currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin ? Colors.red : Colors.blue,
          child: Icon(
            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: user.isAdmin ? Colors.red.shade900 : Colors.blue.shade900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (user.createdAt != null)
              Text(
                'Created: ${dateFormat.format(user.createdAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditUserScreen(
                      authService: widget.authService,
                      user: user,
                    ),
                  ),
                );
                if (result == true) {
                  _loadUsers();
                }
              },
            ),
            if (!isCurrentUser)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(user),
              ),
          ],
        ),
      ),
    );
  }
}
