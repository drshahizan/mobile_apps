import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/document.dart';
import '../models/user.dart';
import 'document_detail_screen.dart';
import 'upload_document_screen.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class AdminHomeScreen extends StatefulWidget {
  final AuthService authService;

  const AdminHomeScreen({super.key, required this.authService});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  List<Document> _documents = [];
  List<Document> _filteredDocuments = [];
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoadingDocuments = true;
  bool _isLoadingUsers = true;
  String? _documentsError;
  String? _usersError;
  final TextEditingController _documentSearchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  String? _selectedTagFilter;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadUsers();
    _documentSearchController.addListener(_filterDocuments);
    _userSearchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _documentSearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _filterDocuments() {
    final query = _documentSearchController.text.toLowerCase();
    setState(() {
      var filtered = _documents;
      
      // Filter by tag first
      if (_selectedTagFilter != null) {
        filtered = filtered.where((doc) => doc.tags == _selectedTagFilter).toList();
      }
      
      // Then filter by search query
      if (query.isNotEmpty) {
        filtered = filtered.where((doc) {
          return doc.title.toLowerCase().contains(query) ||
                 doc.description.toLowerCase().contains(query) ||
                 doc.fileName.toLowerCase().contains(query) ||
                 (doc.uploadedByUsername?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      
      _filteredDocuments = filtered;
    });
  }

  void _filterUsers() {
    final query = _userSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.username.toLowerCase().contains(query) ||
                 user.role.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingDocuments = true;
      _documentsError = null;
    });

    try {
      final documents = await widget.authService.apiService.getDocuments();
      setState(() {
        _documents = documents;
        _filteredDocuments = documents;
        _isLoadingDocuments = false;
      });
    } catch (e) {
      setState(() {
        _documentsError = e.toString();
        _isLoadingDocuments = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });

    try {
      final users = await widget.authService.apiService.getUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _usersError = e.toString();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(authService: widget.authService),
        ),
      );
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
        title: Text(_selectedIndex == 0 ? 'Documents' : 'Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedIndex == 0) {
                _loadDocuments();
              } else {
                _loadUsers();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildDocumentsTab() : _buildUsersTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_selectedIndex == 0) {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    UploadDocumentScreen(authService: widget.authService),
              ),
            );
            if (result == true) {
              _loadDocuments();
            }
          } else {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AddUserScreen(authService: widget.authService),
              ),
            );
            if (result == true) {
              _loadUsers();
            }
          }
        },
        icon: Icon(_selectedIndex == 0 ? Icons.add : Icons.person_add),
        label: Text(_selectedIndex == 0 ? 'Upload' : 'Add User'),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    if (_isLoadingDocuments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_documentsError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocuments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No documents available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _documentSearchController,
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _documentSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _documentSearchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedTagFilter,
                decoration: InputDecoration(
                  labelText: 'Filter by Tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.filter_list),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Tags')),
                  DropdownMenuItem(value: 'procedure', child: Text('Procedure')),
                  DropdownMenuItem(value: 'circular', child: Text('Circular')),
                  DropdownMenuItem(value: 'archive', child: Text('Archive')),
                  DropdownMenuItem(value: 'policy', child: Text('Policy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTagFilter = value;
                    _filterDocuments();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredDocuments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No documents found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  child: ListView.builder(
                    itemCount: _filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = _filteredDocuments[index];
                      return _buildDocumentCard(document);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(Document document) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getFileIcon(document.fileType)),
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.description.isNotEmpty)
              Text(
                document.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '${document.fileSizeFormatted} • ${dateFormat.format(document.uploadedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (document.uploadedByUsername != null)
              Text(
                'By: ${document.uploadedByUsername}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentDetailScreen(
                document: document,
                authService: widget.authService,
              ),
            ),
          );
          if (result == true) {
            _loadDocuments();
          }
        },
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_usersError'),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _userSearchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _userSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _userSearchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
        ),
      ],
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

  IconData _getFileIcon(String fileType) {
    if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('image')) {
      return Icons.image;
    } else if (fileType.contains('word') || fileType.contains('document')) {
      return Icons.description;
    } else if (fileType.contains('excel') || fileType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (fileType.contains('text')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }
}
