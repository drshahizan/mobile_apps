import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../models/document.dart';
import '../services/auth_service.dart';
import 'edit_document_screen.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;
  final AuthService authService;

  const DocumentDetailScreen({
    super.key,
    required this.document,
    required this.authService,
  });

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool _isDownloading = false;
  bool _isDeleting = false;

  Future<void> _downloadDocument() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final filePath = await widget.authService.apiService.downloadDocument(
        widget.document.id,
        widget.document.fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        await OpenFile.open(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
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

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await widget.authService.apiService.deleteDocument(widget.document.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy HH:mm');
    final isAdmin = widget.authService.currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditDocumentScreen(
                          authService: widget.authService,
                          document: widget.document,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isDeleting ? null : _deleteDocument,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getFileIcon(widget.document.fileType),
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.document.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.document.fileName,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      'Description',
                      widget.document.description.isNotEmpty
                          ? widget.document.description
                          : 'No description',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'File Size',
                      widget.document.fileSizeFormatted,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'File Type',
                      widget.document.fileType,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Uploaded By',
                      widget.document.uploadedByUsername ?? 'Unknown',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Uploaded At',
                      dateFormat.format(widget.document.uploadedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadDocument,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Downloading...' : 'Download & Open'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
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
