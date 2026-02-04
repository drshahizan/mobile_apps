import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventory_detail_screen.dart';
import 'add_item_screen.dart';
import '../services/validation_service.dart';
import '../services/activity_logging_service.dart';
import '../widgets/home_action.dart';

class InventoryItem {
  final String id;
  final String code;
  final String name;
  final String description;
  final int quantity;
  final int lowStockThreshold;
  final int safetyStockQuantity;
  final int replenishQuantity;
  final String rackNumber;
  final String rackLevel;
  final String sapNumber;
  final String internalReference;
  final String? pictureUrl;

  InventoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.quantity,
    this.lowStockThreshold = 10,
    this.safetyStockQuantity = 20,
    this.replenishQuantity = 50,
    this.rackNumber = 'A-01',
    this.rackLevel = 'Ground',
    this.sapNumber = 'SAP-00000',
    this.internalReference = 'INT-00000',
    this.pictureUrl,
  });
}

class InventoryListScreen extends StatefulWidget {
  final String? initialFilter;

  const InventoryListScreen({super.key, this.initialFilter});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDeleteMode = false;
  Set<String> _selectedItemsForDelete = {};
  late String _selectedFilter; // All, Low Stock, Out of Stock
  String _sortMode = 'A-Z'; // A-Z or 0-9
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  InventoryItem _convertFirebaseDocToItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Format rack number: pad single digits with 0 (5 → 05, but 19 stays 19)
    final rackNumber = data['rackNumber']?.toString() ?? 'A-01';
    final formattedRackNumber = rackNumber.length == 1 ? '0$rackNumber' : rackNumber;
    
    // Format rack level: uppercase single letter
    final rackLevel = data['rackLevel']?.toString() ?? 'Ground';
    final formattedRackLevel = rackLevel.isNotEmpty ? rackLevel.substring(0, 1).toUpperCase() : 'Ground';
    
    return InventoryItem(
      id: doc.id,
      code: data['sapCode'] ?? '',
      name: (data['name'] ?? '').toString().toUpperCase(),
      description: data['description'] ?? '',
      quantity: (data['currentStock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: 10,
      safetyStockQuantity: (data['maxStock'] as num?)?.toInt() ?? 20,
      replenishQuantity: (data['replenishQty'] as num?)?.toInt() ?? 50,
      rackNumber: formattedRackNumber,
      rackLevel: formattedRackLevel,
      sapNumber: data['sapCode'] ?? 'SAP-00000',
      internalReference: ValidationService.validateInternalReference(data['internalRef']?.toString()) ?? (data['internalRef'] ?? 'INT-00000'),
      pictureUrl: data['pictureUrl'],
    );
  }

  String _getStockStatus(InventoryItem item) {
    final safetyLevel = item.safetyStockQuantity;
    final criticalLevel = (safetyLevel * 0.5).toInt();
    
    // OUT: When actual_quantity < (safety_level × 0.5)
    if (item.quantity < criticalLevel) {
      return 'OUT';
    }
    // LOW: When actual_quantity < safety_level
    else if (item.quantity < safetyLevel) {
      return 'LOW!';
    }
    return '';
  }

  Color _getStockStatusColor(InventoryItem item) {
    final safetyLevel = item.safetyStockQuantity;
    final criticalLevel = (safetyLevel * 0.5).toInt();
    
    if (item.quantity < criticalLevel) {
      return Colors.red;
    } else if (item.quantity < safetyLevel) {
      return Colors.orange;
    }
    return Colors.green;
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      // Get item data before deletion for logging
      final itemDoc = await FirebaseFirestore.instance.collection('inventory').doc(itemId).get();
      final itemName = (itemDoc.data()?['name'] as String?) ?? 'Unknown Item';

      // Delete the item
      await FirebaseFirestore.instance.collection('inventory').doc(itemId).delete();

      // Log the deletion
      final activityLoggingService = ActivityLoggingService();
      await activityLoggingService.logItemDeleted(
        itemId: itemId,
        itemName: itemName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  Future<void> _deleteMultipleItems() async {
    if (_selectedItemsForDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected')),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete ${_selectedItemsForDelete.length} item(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all selected items
    try {
      final deletedCount = _selectedItemsForDelete.length;
      final activityLoggingService = ActivityLoggingService();

      for (final itemId in _selectedItemsForDelete) {
        // Get item data before deletion for logging
        final itemDoc = await FirebaseFirestore.instance.collection('inventory').doc(itemId).get();
        final itemName = (itemDoc.data()?['name'] as String?) ?? 'Unknown Item';

        // Delete the item
        await FirebaseFirestore.instance.collection('inventory').doc(itemId).delete();

        // Log the deletion
        await activityLoggingService.logItemDeleted(
          itemId: itemId,
          itemName: itemName,
        );
      }
      
      if (mounted) {
        setState(() {
          _isDeleteMode = false;
          _selectedItemsForDelete.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$deletedCount item(s) deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting items: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmDialog(String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$itemName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(itemId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: _isDeleteMode
            ? Text('${_selectedItemsForDelete.length} selected')
            : const Text('Inventory Items'),
        elevation: 0,
        backgroundColor: _isDeleteMode ? Colors.red[700] : Colors.blue[700],
        leading: _isDeleteMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isDeleteMode = false;
                    _selectedItemsForDelete.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          if (!_isDeleteMode) ...[
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              tooltip: 'Delete Items',
              onPressed: () {
                setState(() {
                  _isDeleteMode = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Item',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemScreen(),
                  ),
                );
                // Refresh will happen automatically via StreamBuilder
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item added successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Selected',
              onPressed: () => _deleteMultipleItems(),
            ),
          ],
          homeIconButton(context),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items by code, name...',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
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
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),

          // Sort Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _sortMode = 'A-Z';
                      });
                    },
                    child: Text(
                      'Sort A-Z',
                      style: TextStyle(
                        color: _sortMode == 'A-Z'
                            ? Colors.white
                            : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _sortMode == 'A-Z'
                          ? Colors.blue[700]
                          : (isDarkMode ? Colors.grey[850] : Colors.white),
                      side: BorderSide(
                        color: _sortMode == 'A-Z'
                            ? Colors.blue[700]!
                            : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _sortMode = '0-9';
                      });
                    },
                    child: Text(
                      'Sort 0-9',
                      style: TextStyle(
                        color: _sortMode == '0-9'
                            ? Colors.white
                            : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _sortMode == '0-9'
                          ? Colors.blue[700]
                          : (isDarkMode ? Colors.grey[850] : Colors.white),
                      side: BorderSide(
                        color: _sortMode == '0-9'
                            ? Colors.blue[700]!
                            : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    isDarkMode: isDarkMode,
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterButton(
                    label: 'Low Stock',
                    isSelected: _selectedFilter == 'Low Stock',
                    isDarkMode: isDarkMode,
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Low Stock';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterButton(
                    label: 'Out of Stock',
                    isSelected: _selectedFilter == 'Out of Stock',
                    isDarkMode: isDarkMode,
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Out of Stock';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inventory')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Convert and filter items
                List<InventoryItem> items = snapshot.data!.docs
                    .map((doc) => _convertFirebaseDocToItem(doc))
                    .toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  items = items
                      .where((item) =>
                          item.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Apply stock status filter
                if (_selectedFilter == 'Low Stock') {
                  items = items
                      .where((item) {
                        final safetyLevel = item.safetyStockQuantity;
                        return item.quantity < safetyLevel && item.quantity >= (safetyLevel * 0.5).toInt();
                      })
                      .toList();
                } else if (_selectedFilter == 'Out of Stock') {
                  items = items
                      .where((item) {
                        final safetyLevel = item.safetyStockQuantity;
                        return item.quantity < (safetyLevel * 0.5).toInt();
                      })
                      .toList();
                }

                // Sort items based on selected sort mode
                if (_sortMode == 'A-Z') {
                  items.sort((a, b) => a.name.compareTo(b.name));
                } else if (_sortMode == '0-9') {
                  items.sort((a, b) => a.code.compareTo(b.code));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final stockStatus = _getStockStatus(item);
                    final statusColor = _getStockStatusColor(item);
                    final isSelected = _isDeleteMode && _selectedItemsForDelete.contains(item.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.red
                              : (isDarkMode ? Colors.transparent : Colors.grey[200]!),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? (isDarkMode ? Colors.red[900]!.withOpacity(0.3) : Colors.red[50])
                            : (isDarkMode ? Colors.grey[850] : Colors.white),
                      ),
                      child: InkWell(
                        onTap: _isDeleteMode
                            ? () {
                                setState(() {
                                  if (_selectedItemsForDelete.contains(item.id)) {
                                    _selectedItemsForDelete.remove(item.id);
                                  } else {
                                    _selectedItemsForDelete.add(item.id);
                                  }
                                });
                              }
                            : () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InventoryDetailScreen(
                                      docId: item.id,
                                      item: item,
                                    ),
                                  ),
                                );
                                // Refresh the list if any changes were made
                                if (result == true && mounted) {
                                  setState(() {});
                                }
                              },
                        onLongPress: !_isDeleteMode
                            ? () {
                                _showDeleteConfirmDialog(item.id, item.name);
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Checkbox (visible in delete mode)
                              if (_isDeleteMode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Checkbox(
                                    value: _selectedItemsForDelete.contains(item.id),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedItemsForDelete.add(item.id);
                                        } else {
                                          _selectedItemsForDelete.remove(item.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              // Item Picture (100x100)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: item.pictureUrl != null && item.pictureUrl!.isNotEmpty
                                    ? Image.network(
                                        item.pictureUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported_outlined,
                                                  size: 40,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'No image',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.inventory_2_outlined,
                                          size: 40,
                                          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Item Code
                                    Text(
                                      item.code,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Item Name
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Quantity and Status
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Qty: ${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                        if (stockStatus.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              stockStatus,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow Button
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? Colors.blue[700]
            : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
        foregroundColor: isSelected 
            ? Colors.white 
            : (isDarkMode ? Colors.grey[100] : Colors.grey[800]),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: isSelected ? 2 : 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}