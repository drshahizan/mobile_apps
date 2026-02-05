import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';

class UploadDocumentScreen extends StatefulWidget {
  final AuthService authService;

  const UploadDocumentScreen({super.key, required this.authService});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  String _selectedTag = 'procedure';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await widget.authService.apiService.uploadDocument(
        _titleController.text,
        _descriptionController.text,
        _selectedFile!,
        _selectedTag,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _getFileName() {
    if (_selectedFile == null) return 'No file selected';
    return _selectedFile!.path.split(Platform.pathSeparator).last;
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';
    final bytes = _selectedFile!.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedTag,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                items: const [
                  DropdownMenuItem(value: 'procedure', child: Text('Procedure')),
                  DropdownMenuItem(value: 'circular', child: Text('Circular')),
                  DropdownMenuItem(value: 'archive', child: Text('Archive')),
                  DropdownMenuItem(value: 'policy', child: Text('Policy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: InkWell(
                  onTap: _isUploading ? null : _pickFile,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFile == null
                              ? Icons.upload_file
                              : Icons.insert_drive_file,
                          size: 64,
                          color: _selectedFile == null
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getFileName(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: _selectedFile == null
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _getFileSize(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _isUploading ? null : _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: Text(
                            _selectedFile == null
                                ? 'Select File'
                                : 'Change File',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadDocument,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload Document'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
