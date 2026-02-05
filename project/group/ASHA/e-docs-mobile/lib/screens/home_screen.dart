import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/document.dart';
import 'document_detail_screen.dart';
import 'upload_document_screen.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Document> _documents = [];
  List<Document> _filteredDocuments = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTagFilter;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
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

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await widget.authService.apiService.getDocuments();
      setState(() {
        _documents = documents;
        _filteredDocuments = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Docs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        UploadDocumentScreen(authService: widget.authService),
                  ),
                );
                if (result == true) {
                  _loadDocuments();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Upload'),
            )
          : null,
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
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
