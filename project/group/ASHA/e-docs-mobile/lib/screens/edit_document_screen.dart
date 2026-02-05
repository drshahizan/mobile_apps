import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/document.dart';

class EditDocumentScreen extends StatefulWidget {
  final AuthService authService;
  final Document document;

  const EditDocumentScreen({
    super.key,
    required this.authService,
    required this.document,
  });

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedTag;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _descriptionController = TextEditingController(text: widget.document.description);
    _selectedTag = widget.document.tags;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.authService.apiService.updateDocument(
        widget.document.id,
        _titleController.text,
        _descriptionController.text,
        _selectedTag,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to update document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Icons.insert_drive_file,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.document.fileName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${widget.document.fileSizeFormatted}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateDocument,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Updating...' : 'Update Document'),
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
