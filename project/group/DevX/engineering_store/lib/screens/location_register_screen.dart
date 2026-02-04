import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class LocationRegisterScreen extends StatefulWidget {
  const LocationRegisterScreen({super.key});

  @override
  State<LocationRegisterScreen> createState() => _LocationRegisterScreenState();
}

class _LocationRegisterScreenState extends State<LocationRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rackNumberController = TextEditingController();
  final _rackLevelController = TextEditingController();
  final _registerByController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-populate Register by field with logged-in user's email username (without @email.com)
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      final userName = user!.email!.split('@').first;
      _registerByController.text = userName;
    }
  }

  @override
  void dispose() {
    _rackNumberController.dispose();
    _rackLevelController.dispose();
    _registerByController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final timestamp = DateTime.now();

      // Save to Firestore locations collection
      final docRef = await FirebaseFirestore.instance.collection('locations').add({
        'rackNumber': _rackNumberController.text.trim(),
        'rackLevel': _rackLevelController.text.trim(),
        'registerBy': _registerByController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'date': timestamp.toIso8601String(),
        'createdAt': timestamp,
      });

      // Log to activity logs
      final activityLoggingService = ActivityLoggingService();
      await activityLoggingService.logLocationAdded(
        locationId: docRef.id,
        locationName: '${_rackNumberController.text.trim()}-${_rackLevelController.text.trim()}',
        locationData: {
          'rackNumber': _rackNumberController.text.trim(),
          'rackLevel': _rackLevelController.text.trim(),
          'registeredBy': _registerByController.text.trim(),
        },
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location registered successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to Location Management
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering location: $e')),
      );
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
        title: Row(
          children: [
            const Icon(Icons.add_location, size: 24),
            const SizedBox(width: 8),
            const Text('Register Location'),
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
                        'Register rack number and rack level',
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

              // Rack Number Field
              const Text(
                'Rack Number *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rackNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter rack number (e.g., 01)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rack Number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rack Level Field
              const Text(
                'Rack Level *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rackLevelController,
                decoration: InputDecoration(
                  hintText: 'Enter rack level (e.g., A,B,C,D)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rack Level is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Register By Field (Auto-filled, Read-only)
              const Text(
                'Register by',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _registerByController.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Timestamp (Auto-generated)
              const Text(
                'Timestamp',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateTime.now().toString().split('.')[0],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register'),
                    ),
                  ),
                ],
              ),
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
}
