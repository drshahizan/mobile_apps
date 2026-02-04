import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/services.dart';
import '../services/validation_service.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
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

  String? _sapExistsError;
  Timer? _sapCheckDebounce;
  String? _internalRefExistsError;
  Timer? _internalRefCheckDebounce;

  bool _saving = false;
  io.File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    // Clean up temp files when screen is disposed
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
    _sapCheckDebounce?.cancel();
    _internalRefCheckDebounce?.cancel();
    super.dispose();
  }

  void _scheduleSapExistsCheck() {
    _sapCheckDebounce?.cancel();
    final sapCode = _sapController.text.trim();
    if (sapCode.isEmpty) return;

    final formatError = ValidationService.validateSapNumber(sapCode);
    if (formatError != null) return;

    _sapCheckDebounce = Timer(const Duration(milliseconds: 400), () async {
      final error = await ValidationService.checkSapNumberExists(sapCode);
      if (!mounted) return;
      if (error != _sapExistsError) {
        setState(() {
          _sapExistsError = error;
        });
        _formKey.currentState?.validate();
      }
    });
  }

  void _scheduleInternalRefExistsCheck() {
    _internalRefCheckDebounce?.cancel();
    final internalRef = _internalRefController.text.trim();
    if (internalRef.isEmpty) return;

    final formatError =
        ValidationService.validateInternalReferenceFormat(internalRef);
    if (formatError != null) return;

    _internalRefCheckDebounce = Timer(const Duration(milliseconds: 400), () async {
      final error = await ValidationService.checkInternalRefExists(internalRef);
      if (!mounted) return;
      if (error != _internalRefExistsError) {
        setState(() {
          _internalRefExistsError = error;
        });
        _formKey.currentState?.validate();
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Processing image...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        try {
          // Read and process image
          final bytes = await pickedFile.readAsBytes();

          if (mounted) {
            // Detect file type from extension
            final fileExtension = pickedFile.path.split('.').last.toLowerCase();
            final isPng = fileExtension == 'png';

            // Resize image
            img.Image? image = img.decodeImage(bytes);

            if (image != null) {
              // Resize to 100x100
              img.Image resized = img.copyResize(
                image,
                width: 100,
                height: 100,
                interpolation: img.Interpolation.linear,
              );

              // Get temp directory and save
              final tempDir = await getTemporaryDirectory();
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final fileExt = isPng ? 'png' : 'jpg';
              final tempPath =
                  '${tempDir.path}${io.Platform.pathSeparator}resized_${timestamp}.$fileExt';

              final tempFile = io.File(tempPath);

              // Encode based on file type
              final encodedBytes = isPng
                  ? img.encodePng(resized)
                  : img.encodeJpg(resized, quality: 90);

              await tempFile.writeAsBytes(encodedBytes);

              if (mounted) {
                setState(() {
                  _selectedImage = tempFile;
                });
              }
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

  Future<String?> _uploadImage(String itemId) async {
    if (_selectedImage == null) return null;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Uploading image to Firebase...'),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Get file metadata
      final file = _selectedImage!;
      final fileSize = await file.length();
      final fileName = file.path.split(io.Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      print('Uploading file size: ${fileSize / 1024}KB');

      // Validate file size (2MB limit for PNG support)
      if (fileSize > 2 * 1024 * 1024) {
        throw Exception(
            'Image too large. Max 2MB. Current: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      }

      // Create unique filename with timestamp and correct extension
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('inventory_images')
          .child(
              '${itemId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension');

      // Set correct content type based on file extension
      final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

      // Add metadata for better organization
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'itemId': itemId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'dimensions': '100x100',
          'format': fileExtension.toUpperCase(),
        },
      );

      // Upload to Firebase Storage
      await storageRef.putFile(file, metadata);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image uploaded successfully to Firebase Storage'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Clean up temp file after successful upload
      await _cleanupTempFile();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
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

        // Only delete temp files (those starting with 'resized_')
        if (fileName.startsWith('resized_')) {
          await _selectedImage!.delete();
          print('🗑️ Temp file deleted: $fileName');
        }
      }
    } catch (e) {
      print('Error cleaning temp file: $e');
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if image is selected
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select an image for the item'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final sapCode = _sapController.text.trim();

      // Check if SAP Number already exists
      final sapExistsError =
          await ValidationService.checkSapNumberExists(sapCode);
      if (sapExistsError != null) {
        if (mounted) {
          setState(() {
            _sapExistsError = sapExistsError;
          });
          _formKey.currentState?.validate();
        }
        if (mounted) {
          setState(() => _saving = false);
        }
        return;
      }

      final internalRef = (ValidationService.validateInternalReference(
                  _internalRefController.text.trim()) ??
              _internalRefController.text.trim())
          .toUpperCase();
      final description = _descriptionController.text.trim();
      final safetyLevel = int.parse(_safetyLevelController.text.trim());
      final replenishQty = int.parse(_replenishQtyController.text.trim());
      final actualQty = int.parse(_actualQtyController.text.trim());
      final rackNumberRaw = _rackNumberController.text.trim();
      final rackNumber =
          rackNumberRaw.length == 1 ? '0$rackNumberRaw' : rackNumberRaw;
      final rackLevel = _rackLevelController.text.trim();
      final name = _nameController.text.trim().toUpperCase();
      final location = 'Rack $rackNumber - Level $rackLevel';

      final docRef =
          await FirebaseFirestore.instance.collection('inventory').add({
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
        'recentActivity': [
          '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')} - Initial stock: $actualQty',
        ],
      });

      if (_selectedImage != null) {
        final pictureUrl = await _uploadImage(docRef.id);
        if (pictureUrl != null) {
          await docRef.update({'pictureUrl': pictureUrl});
        }
      }

      // Log to activity logs
      final activityLoggingService = ActivityLoggingService();
      await activityLoggingService.logItemAdded(
        itemId: docRef.id,
        itemName: name,
        itemData: {
          'sapCode': sapCode,
          'description': description,
          'maxStock': safetyLevel,
          'initialStock': actualQty,
          'rackNumber': rackNumber,
          'rackLevel': rackLevel,
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: $e')),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [homeIconButton(context)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.blue[900]?.withOpacity(0.3)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_box_outlined,
                          color: Colors.blue[700], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add new item to inventory. All fields marked with * are required.',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          height: 1.4,
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sapController,
                decoration: InputDecoration(
                  hintText: 'e.g. 7000001',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                onChanged: (_) {
                  if (_sapExistsError != null) {
                    setState(() {
                      _sapExistsError = null;
                    });
                  }
                  _scheduleSapExistsCheck();
                },
                onEditingComplete: _scheduleSapExistsCheck,
                onFieldSubmitted: (_) => _scheduleSapExistsCheck(),
                validator: (value) {
                  final formatError = ValidationService.validateSapNumber(value);
                  if (formatError != null) {
                    return formatError;
                  }
                  return _sapExistsError;
                },
              ),
              const SizedBox(height: 16),

              // Item Name
              const Text(
                'Item Name *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Bearing 6200',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.label_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) {
                  // Convert to uppercase as user types
                  if (value.isNotEmpty && value != value.toUpperCase()) {
                    _nameController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.fromPosition(
                          TextPosition(offset: value.length)),
                    );
                    return;
                  }
                },
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _internalRefController,
                decoration: InputDecoration(
                  hintText: 'e.g. AA 111, AAA 111, AAAA 111, AA 1111',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.tag),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  final formatError =
                      ValidationService.validateInternalReferenceFormat(value);
                  if (formatError != null) {
                    return formatError;
                  }
                  return _internalRefExistsError;
                },
                onChanged: (value) {
                  final upper = value.toUpperCase();
                  if (upper != value) {
                    _internalRefController.value = TextEditingValue(
                      text: upper,
                      selection: TextSelection.fromPosition(
                          TextPosition(offset: upper.length)),
                    );
                    _scheduleInternalRefExistsCheck();
                    return;
                  }

                  // Format the input as user types when valid
                  final formatted =
                      ValidationService.validateInternalReference(upper);
                  if (formatted != null && formatted != upper) {
                    _internalRefController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.fromPosition(
                          TextPosition(offset: formatted.length)),
                    );
                    _scheduleInternalRefExistsCheck();
                    return;
                  }
                  _scheduleInternalRefExistsCheck();
                },
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Description *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter item description...',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
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

              // Safety Stock Level
              const Text(
                'Safety Stock Level *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _safetyLevelController,
                decoration: InputDecoration(
                  hintText: '0',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.safety_check_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Safety Stock Level is required';
                  }
                  final intValue = int.tryParse(value.trim());
                  if (intValue == null || intValue < 0) {
                    return 'Must be a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Replenish Quantity
              const Text(
                'Replenish Quantity *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _replenishQtyController,
                decoration: InputDecoration(
                  hintText: '0',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.restore_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Replenish Quantity is required';
                  }
                  final intValue = int.tryParse(value.trim());
                  if (intValue == null || intValue < 0) {
                    return 'Must be a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Actual Quantity
              const Text(
                'Actual Quantity *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _actualQtyController,
                decoration: InputDecoration(
                  hintText: '0',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onTap: _scheduleSapExistsCheck,
                onChanged: (_) => _scheduleSapExistsCheck(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Actual Quantity is required';
                  }
                  final intValue = int.tryParse(value.trim());
                  if (intValue == null || intValue < 0) {
                    return 'Must be a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rack Number
              const Text(
                'Rack Number *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rackNumberController,
                decoration: InputDecoration(
                  hintText: '0',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.shelves),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onEditingComplete: () {
                  final value = _rackNumberController.text.trim();
                  if (value.length == 1) {
                    final padded = '0$value';
                    _rackNumberController.value = TextEditingValue(
                      text: padded,
                      selection: TextSelection.fromPosition(
                          TextPosition(offset: padded.length)),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rack Number is required';
                  }
                  if (!RegExp(r'^\d{1,2}$').hasMatch(value.trim())) {
                    return 'Rack Number must be 1-2 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rack Level
              const Text(
                'Rack Level *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rackLevelController,
                decoration: InputDecoration(
                  hintText: 'ABCD',
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
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.layers_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                ],
                onChanged: (value) {
                  // Convert to uppercase as user types
                  if (value.isNotEmpty && value != value.toUpperCase()) {
                    _rackLevelController.text = value.toUpperCase();
                    _rackLevelController.selection = TextSelection.fromPosition(
                        TextPosition(offset: 1));
                    return;
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rack Level is required';
                  }
                  if (value.length > 1) {
                    return 'Rack Level must be a single character';
                  }
                  if (!RegExp(r'^[A-Z]$').hasMatch(value.toUpperCase())) {
                    return 'Rack Level must be a letter (A-Z)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image Picker Section
              const Text(
                'Item Picture *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.blue[900]?.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upload 100x100px image',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.photo_camera_outlined,
                                    size: 32,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _pickImage,
                            icon:
                                const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text('Select Image'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Creation Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateTime.now().toString().split('.')[0],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'SAVE ITEM',
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
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
