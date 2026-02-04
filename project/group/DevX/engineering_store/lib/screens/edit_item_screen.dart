import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import '../services/activity_logging_service.dart';
import 'package:flutter/services.dart';
import '../services/validation_service.dart';
import '../widgets/home_action.dart';

class EditItemScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> itemData;

  const EditItemScreen({
    super.key,
    required this.documentId,
    required this.itemData,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sapController = TextEditingController();
  final _internalRefController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _safetyLevelController = TextEditingController();
  final _replenishQtyController = TextEditingController();
  final _actualQtyController = TextEditingController();
  final _rackNumberController = TextEditingController();
  final _rackLevelController = TextEditingController();
  final _nameController = TextEditingController();

  bool _saving = false;
  bool _loading = true;
  io.File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    try {
      final data = widget.itemData;

      _sapController.text = data['sapCode']?.toString() ?? '';
      _nameController.text = (data['name']?.toString() ?? '').toUpperCase();
      _internalRefController.text = ValidationService.validateInternalReference(data['internalRef']?.toString()) ?? (data['internalRef']?.toString() ?? '');
      _descriptionController.text = data['description']?.toString() ?? '';
      _safetyLevelController.text = data['maxStock']?.toString() ?? '0';
      _replenishQtyController.text = data['replenishQty']?.toString() ?? '0';
      _actualQtyController.text = data['currentStock']?.toString() ?? '0';
      
      // Format rack number: pad single digits with 0 (5 → 05, but 19 stays 19)
      final rackNum = data['rackNumber']?.toString() ?? '';
      _rackNumberController.text = rackNum.isNotEmpty && rackNum.length == 1 && rackNum != '0' ? '0$rackNum' : rackNum;
      
      // Format rack level: uppercase single letter
      final rackLvl = data['rackLevel']?.toString() ?? '';
      _rackLevelController.text = rackLvl.isNotEmpty ? rackLvl.substring(0, 1).toUpperCase() : rackLvl;
      _existingImageUrl = data['pictureUrl']?.toString();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error loading item data: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  void dispose() {
    _cleanupTempFile();
    _sapController.dispose();
    _internalRefController.dispose();
    _descriptionController.dispose();
    _safetyLevelController.dispose();
    _replenishQtyController.dispose();
    _actualQtyController.dispose();
    _rackNumberController.dispose();
    _rackLevelController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔄 Processing image...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        try {
          final bytes = await pickedFile.readAsBytes();
          final fileExtension = pickedFile.path.split('.').last.toLowerCase();
          final isPng = fileExtension == 'png';

          img.Image? image = img.decodeImage(bytes);

          if (image != null) {
            img.Image resized = img.copyResize(
              image,
              width: 100,
              height: 100,
              interpolation: img.Interpolation.linear,
            );

            final tempDir = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileExt = isPng ? 'png' : 'jpg';
            final tempPath =
                '${tempDir.path}${io.Platform.pathSeparator}resized_${timestamp}.$fileExt';

            final tempFile = io.File(tempPath);

            final encodedBytes = isPng
                ? img.encodePng(resized)
                : img.encodeJpg(resized, quality: 90);

            await tempFile.writeAsBytes(encodedBytes);

            if (mounted) {
              setState(() {
                _selectedImage = tempFile;
              });

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Image resized to 100x100px'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (processError) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('❌ Error processing image: $processError')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    try {
      if (_existingImageUrl != null) {
        final storageRef =
            FirebaseStorage.instance.refFromURL(_existingImageUrl!);
        await storageRef.delete();
      }

      setState(() {
        _selectedImage = null;
        _existingImageUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Image removed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error removing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage(String itemId) async {
    if (_selectedImage == null) return null;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Uploading image...'),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final file = _selectedImage!;
      final fileSize = await file.length();
      final fileName = file.path.split(io.Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      if (fileSize > 2 * 1024 * 1024) {
        throw Exception(
            'Image too large. Max 2MB. Current: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      }

      // First delete existing image if any
      if (_existingImageUrl != null) {
        try {
          final oldStorageRef =
              FirebaseStorage.instance.refFromURL(_existingImageUrl!);
          await oldStorageRef.delete();
        } catch (e) {
          print('Warning: Could not delete old image: $e');
        }
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('inventory_images')
          .child(
              '${itemId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension');

      final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'itemId': itemId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'dimensions': '100x100',
          'format': fileExtension.toUpperCase(),
        },
      );

      await storageRef.putFile(file, metadata);
      final downloadUrl = await storageRef.getDownloadURL();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image uploaded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await _cleanupTempFile();

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _cleanupTempFile() async {
    try {
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split('/').last;
        if (fileName.startsWith('resized_')) {
          await _selectedImage!.delete();
        }
      }
    } catch (e) {
      print('Error cleaning temp file: $e');
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final sapCode = _sapController.text.trim();

      // Check if SAP Number already exists (exclude current document)
      final sapExistsError = await ValidationService.checkSapNumberExists(
        sapCode,
        excludeDocId: widget.documentId,
      );
      if (sapExistsError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(sapExistsError),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (mounted) {
          setState(() => _saving = false);
        }
        return;
      }

      final internalRef = ValidationService.validateInternalReference(
              _internalRefController.text.trim()) ??
          _internalRefController.text.trim();
      final description = _descriptionController.text.trim();
      final safetyLevel = int.parse(_safetyLevelController.text.trim());
      final replenishQty = int.parse(_replenishQtyController.text.trim());
      final actualQty = int.parse(_actualQtyController.text.trim());
      final rackNumber = _rackNumberController.text.trim();
      final rackLevel = _rackLevelController.text.trim();
      final name = _nameController.text.trim().toUpperCase();
      final location = 'Rack $rackNumber - Level $rackLevel';

      final updateData = {
        'sapCode': sapCode,
        'name': name,
        'internalRef': internalRef,
        'description': description,
        'maxStock': safetyLevel,
        'replenishQty': replenishQty,
        'currentStock': actualQty,
        'rackNumber': rackNumber,
        'rackLevel': rackLevel,
        'location': location,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      final oldData = widget.itemData;
      final activityEntries = [];

      if (oldData['currentStock'] != actualQty) {
        activityEntries.add(
          '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')} - Stock updated from ${oldData['currentStock']} to $actualQty',
        );
      }

      if (activityEntries.isNotEmpty) {
        updateData['recentActivity'] = FieldValue.arrayUnion(activityEntries);
      }

      if (_selectedImage != null) {
        final pictureUrl = await _uploadImage(widget.documentId);
        if (pictureUrl != null) {
          updateData['pictureUrl'] = pictureUrl;
        }
      } else if (_existingImageUrl == null) {
        updateData['pictureUrl'] = FieldValue.delete();
      }

      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(widget.documentId)
          .update(updateData);

      // Log to activity logs
      Map<String, dynamic> changes = {};

      if (oldData['name'] != name) {
        changes['name'] = {'old': oldData['name'], 'new': name};
      }
      if (oldData['currentStock'] != actualQty) {
        changes['quantity'] = {
          'old': oldData['currentStock'],
          'new': actualQty
        };
      }
      if (oldData['rackNumber'] != rackNumber ||
          oldData['rackLevel'] != rackLevel) {
        changes['location'] = {
          'old': '${oldData['rackNumber']}-${oldData['rackLevel']}',
          'new': '$rackNumber-$rackLevel'
        };
      }
      if (oldData['description'] != description) {
        changes['description'] = {
          'old': oldData['description'],
          'new': description
        };
      }
      if (oldData['maxStock'] != safetyLevel) {
        changes['maxStock'] = {'old': oldData['maxStock'], 'new': safetyLevel};
      }

      if (changes.isNotEmpty) {
        final activityLoggingService = ActivityLoggingService();
        await activityLoggingService.logItemEdited(
          itemId: widget.documentId,
          itemName: name,
          changes: changes,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Item updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to update item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        elevation: 0,
        backgroundColor: Colors.orange[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
        actions: [homeIconButton(context)],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading item data...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Edit existing inventory item. Changes will update the item information.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SAP Number
                    const Text(
                      'SAP Number *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sapController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 7000001',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                      validator: ValidationService.validateSapNumber,
                    ),
                    const SizedBox(height: 16),

                    // Item Name
                    const Text(
                      'Item Name *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Bearing 6200',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Item Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Internal Reference
                    const Text(
                      'Internal Reference No. *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _internalRefController,
                      decoration: InputDecoration(
                        hintText: 'e.g. AA 111, AAA 111, AAAA 111, AA 1111',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.tag),
                      ),
                      validator:
                          ValidationService.validateInternalReferenceFormat,
                      onChanged: (value) {
                        // Format the input as user types
                        final formatted =
                            ValidationService.validateInternalReference(value);
                        if (formatted != null && formatted != value) {
                          _internalRefController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.fromPosition(
                                TextPosition(offset: formatted.length)),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter item description...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Storage Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rack Number *',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _rackNumberController,
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.shelves, size: 20),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rack Level *',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _rackLevelController,
                                      decoration: InputDecoration(
                                        hintText: 'ABCD',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.layers, size: 20),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image Section
                    const Text(
                      'Item Picture',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.image, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Upload or update 100x100px image',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : _existingImageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  _existingImageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 32,
                                                        color: Colors.grey[400],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.photo_camera,
                                                  size: 32,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                  ),
                                  if (_existingImageUrl != null ||
                                      _selectedImage != null)
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed:
                                            _saving ? null : _removeImage,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _saving ? null : _pickImage,
                                      icon:
                                          const Icon(Icons.add_photo_alternate),
                                      label: const Text('Select New Image'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_existingImageUrl != null)
                                      Text(
                                        'Current image will be replaced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Timestamp Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Updated',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                DateTime.now().toString().split('.')[0],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Editing',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'UPDATE ITEM',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Footer
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
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
}
