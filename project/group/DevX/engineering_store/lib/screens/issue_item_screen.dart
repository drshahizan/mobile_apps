import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class IssueItemScreen extends StatefulWidget {
  const IssueItemScreen({super.key});

  @override
  State<IssueItemScreen> createState() => _IssueItemScreenState();
}
class _IssueItemScreenState extends State<IssueItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _sapCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _usageLocationController = TextEditingController();
  final _technicianNameController = TextEditingController();

  // State Variables
  String? _selectedSapCode;
  String? _selectedItemName;
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  @override
  void dispose() {
    _sapCodeController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _usageLocationController.dispose();
    _technicianNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('inventory').get();

      setState(() {
        _inventoryItems = snapshot.docs
            .map((doc) => {
                  'sapCode': doc['sapCode'] ?? '',
                  'name': doc['name'] ?? '',
                  'docId': doc.id,
                  'currentStock': (doc['currentStock'] as num?)?.toInt() ?? 0,
                })
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final timestamp = DateTime.now();
      final sapCode = _sapCodeController.text.trim();
      final itemName = _itemNameController.text.trim();
      final quantityText = _quantityController.text.trim();
      final usageLocation = _usageLocationController.text.trim();
      final technicianName = _technicianNameController.text.trim();

      final quantityIssued = int.tryParse(quantityText) ?? 0;

      if (quantityIssued <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity must be greater than 0')),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      // Find the inventory item
      final itemMatch = _inventoryItems.firstWhere(
        (item) => item['sapCode'] == sapCode,
        orElse: () => <String, dynamic>{},
      );

      if (itemMatch.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item not found. Please select a valid item.')),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      final itemDocId = itemMatch['docId'];
      final currentStock = itemMatch['currentStock'] as int;

      // Check if sufficient stock available
      if (quantityIssued > currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Insufficient stock. Available: $currentStock units')),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      // 1. Save to issuance collection
      await FirebaseFirestore.instance.collection('issuance').add({
        'sapCode': sapCode,
        'itemName': itemName,
        'quantityIssued': quantityIssued,
        'usageLocation': usageLocation,
        'technicianName': technicianName,
        'remarks': '',
        'timestamp': FieldValue.serverTimestamp(),
        'date': timestamp.toIso8601String(),
        'status': 'Completed',
      });

      // 2. Log to activity logs (replaces movement_logs)
      final activityLoggingService = ActivityLoggingService();
      await activityLoggingService.logIssueItem(
        itemId: itemDocId,
        itemName: itemName,
        quantity: quantityIssued,
        recipient: technicianName,
        remarks: 'Usage Location: $usageLocation',
      );

      // 3. Update inventory item - decrease current stock
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(itemDocId)
          .update({
        'currentStock': FieldValue.increment(-quantityIssued),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 4. Add to activity log
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(itemDocId)
          .update({
        'recentActivity': FieldValue.arrayUnion([
          '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} - Issued $quantityIssued units to $usageLocation'
        ])
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item issued successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form and return to previous screen
      _formKey.currentState!.reset();
      _selectedSapCode = null;
      _selectedItemName = null;
      _sapCodeController.clear();
      _itemNameController.clear();
      _quantityController.clear();
      _usageLocationController.clear();
      _technicianNameController.clear();

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving issuance: $e')),
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
        title: Row(
          children: [
            const Icon(Icons.outbox_outlined, size: 24),
            const SizedBox(width: 8),
            const Text('Issue Item'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                              'Record item issued to end user',
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

                    // SAP Number Dropdown
                    const Text('SAP Number *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSapCode,
                      hint: const Text('Select SAP Number'),
                      items: _inventoryItems
                          .where(
                              (item) => (item['sapCode'] as String).isNotEmpty)
                          .map((item) => DropdownMenuItem<String>(
                                value: item['sapCode'] as String,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item['sapCode']} - ${(item['name'] ?? '').toString().toUpperCase()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Stock: ${item['currentStock']} units',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return _inventoryItems
                            .where((item) =>
                                (item['sapCode'] as String).isNotEmpty)
                            .map((item) => Text(
                                  item['sapCode'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ))
                            .toList();
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedSapCode = value;
                          if (value != null) {
                            try {
                              final selectedItem = _inventoryItems
                                  .firstWhere(
                                      (item) => item['sapCode'] == value)
                                  .cast<String, dynamic>();
                              _selectedItemName =
                                  (selectedItem['name'] as String).toUpperCase();
                              _itemNameController.text =
                                  _selectedItemName ?? '';
                              _sapCodeController.text = value;
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Error loading item details')),
                              );
                            }
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a SAP Number' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item Name (Read-only)
                    const Text('Item Name *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _itemNameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Item name will appear here',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity Needed
                    const Text('Quantity Needed *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter quantity',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Usage Location
                    const Text('Usage Location *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usageLocationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'e.g., Workshop A, Department B',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter usage location'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Technician Name
                    const Text('Technician Name *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _technicianNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter technician name',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter technician name'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Issue Item',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
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
