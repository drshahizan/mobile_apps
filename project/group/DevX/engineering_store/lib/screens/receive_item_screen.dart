import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class ReceiveItemScreen extends StatefulWidget {
  const ReceiveItemScreen({super.key});

  @override
  State<ReceiveItemScreen> createState() => _ReceiveItemScreenState();
}

class _ReceiveItemScreenState extends State<ReceiveItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();

  // State Variables
  String? _selectedSapCode;
  String? _selectedItemName;
  final _itemNameController = TextEditingController();
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
    _supplierController.dispose();
    _quantityController.dispose();
    _remarksController.dispose();
    _itemNameController.dispose();
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
            .where((item) => (item['sapCode'] as String).isNotEmpty)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  Future<void> _submitReceiving() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final timestamp = DateTime.now();
      final quantityReceived = int.parse(_quantityController.text.trim());
      final supplier = _supplierController.text.trim();
      final remarks = _remarksController.text.trim();

      // Find the item document ID
      final itemMatch = _inventoryItems
          .where((item) => item['sapCode'] == _selectedSapCode)
          .firstOrNull;

      if (itemMatch == null) {
        if (!mounted) return;
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

      // 1. Save to receivings collection
      await FirebaseFirestore.instance.collection('receivings').add({
        'sapCode': _selectedSapCode,
        'itemName': _selectedItemName,
        'quantityReceived': quantityReceived,
        'supplier': supplier,
        'remarks': remarks,
        'timestamp': FieldValue.serverTimestamp(),
        'date': timestamp.toIso8601String(),
        'status': 'Completed',
      });

      // 2. Log to activity logs (replaces movement_logs)
      final activityLoggingService = ActivityLoggingService();
      await activityLoggingService.logReceiveItem(
        itemId: itemDocId,
        itemName: _selectedItemName!,
        quantity: quantityReceived,
        source: supplier,
        remarks: remarks,
      );

      // 3. Update inventory item - increase current stock
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(itemDocId)
          .update({
        'currentStock': FieldValue.increment(quantityReceived),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 4. Add to activity log
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(itemDocId)
          .update({
        'recentActivity': FieldValue.arrayUnion([
          '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} - Received $quantityReceived units from $supplier'
        ])
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item received successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form and return to previous screen
      _formKey.currentState!.reset();
      _selectedSapCode = null;
      _selectedItemName = null;
      _supplierController.clear();
      _quantityController.clear();
      _remarksController.clear();

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving receiving: $e')),
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
            const Icon(Icons.inbox_outlined, size: 24),
            const SizedBox(width: 8),
            const Text('Receive Item'),
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
                              'Record item receive from supplier',
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
                    const Text(
                      'SAP Number *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSapCode,
                      decoration: InputDecoration(
                        hintText: 'Select item SAP number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.inventory_2),
                      ),
                      items: _inventoryItems
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
                                      'Stock: ${item['currentStock'] ?? 0} units',
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
                          if (value != null && value.isNotEmpty) {
                            try {
                              _selectedItemName = _inventoryItems.firstWhere(
                                      (item) =>
                                          item['sapCode'] == value)['name']
                                  as String?;
                              _itemNameController.text =
                                  _selectedItemName ?? '';
                            } catch (e) {
                              _selectedItemName = null;
                              _itemNameController.text = '';
                            }
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'SAP Number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Item Name (Read-only)
                    const Text(
                      'Item Name *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _itemNameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Item name will appear here',
                        prefixIcon: const Icon(Icons.label),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity Received
                    const Text(
                      'Quantity Received *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Enter quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            const Icon(Icons.production_quantity_limits),
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        final intValue = int.tryParse(value.trim());
                        if (intValue == null || intValue <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Supplier Name
                    const Text(
                      'Supplier Name *',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _supplierController,
                      decoration: InputDecoration(
                        labelText: 'Enter supplier name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.business),
                        hintText: 'e.g. ABC Supplies Inc.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Supplier name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Remarks
                    const Text(
                      'Remarks (Optional)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _remarksController,
                      decoration: InputDecoration(
                        labelText: 'Add any notes or remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.note_alt),
                        hintText: 'e.g. Partial delivery, Quality check passed',
                      ),
                      maxLines: 3,
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
                                'Transaction Time',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submitReceiving,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
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
                                'CONFIRM RECEIVING',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
