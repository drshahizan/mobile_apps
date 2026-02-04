import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'edit_item_screen.dart';
import 'inventory_list_screen.dart';
import '../services/validation_service.dart';
import '../widgets/home_action.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({super.key, this.docId, this.item});

  final String? docId;
  final InventoryItem? item;

  String _getStockStatus(int current, int safety) {
    if (current == 0) return 'OUT OF STOCK';
    if (current < safety) return 'LOW STOCK';
    return 'OK';
  }

  Color _getStatusColor(String status) {
    if (status.contains('OUT')) return Colors.red;
    if (status.contains('LOW')) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('OUT')) return Icons.cancel;
    if (status.contains('LOW')) return Icons.warning;
    return Icons.check_circle;
  }

  // Helper methods for sample data display
  String _getStockStatusText(InventoryItem item) {
    if (item.quantity == 0) {
      return 'OUT OF STOCK';
    } else if (item.quantity <= item.lowStockThreshold) {
      return 'LOW STOCK';
    }
    return 'IN STOCK';
  }

  Color _getStockStatusColor(InventoryItem item) {
    if (item.quantity == 0) {
      return Colors.red;
    } else if (item.quantity <= item.lowStockThreshold) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // If item is provided (from local sample data), show local detail view
    if (item != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          backgroundColor: Colors.blue[700],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [homeIconButton(context)],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.blue[50],
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.blue[200]!,
                  ),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Picture
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: item!.pictureUrl != null &&
                                  item!.pictureUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item!.pictureUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 32,
                                          color: isDarkMode
                                              ? Colors.grey[600]
                                              : Colors.grey[400],
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 32,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item!.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item!.code,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStockStatusColor(item!)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getStockStatusColor(item!),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _getStockStatusText(item!),
                                  style: TextStyle(
                                    color: _getStockStatusColor(item!),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
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

              // Stock Information Section
              _buildDetailSection(
                context,
                title: 'Stock Information',
                icon: Icons.bar_chart_outlined,
                isDarkMode: isDarkMode,
                children: [
                  _buildDetailRow('SAP Number', item!.sapNumber, isDarkMode),
                  _buildDetailRow('Item Name', item!.name, isDarkMode),
                  _buildDetailRow('Internal Reference', item!.internalReference,
                      isDarkMode),
                  _buildDetailRow('Safety Level',
                      item!.safetyStockQuantity.toString(), isDarkMode),
                  _buildDetailRow('Replenish Quantity',
                      item!.replenishQuantity.toString(), isDarkMode),
                  _buildDetailRow(
                      'Actual Quantity', item!.quantity.toString(), isDarkMode),
                  _buildDetailRow('Rack Number', item!.rackNumber, isDarkMode),
                  _buildDetailRow('Rack Level', item!.rackLevel, isDarkMode),
                ],
              ),
              const SizedBox(height: 20),

              // Description Section
              _buildDetailSection(
                context,
                title: 'Description',
                icon: Icons.description_outlined,
                isDarkMode: isDarkMode,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: docId != null
                          ? () async {
                              final doc = await FirebaseFirestore.instance
                                  .collection('inventory')
                                  .doc(docId)
                                  .get();
                              if (doc.exists && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditItemScreen(
                                      documentId: docId!,
                                      itemData: doc.data()!,
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Adjust Stock'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        docId != null
                            ? _showAdjustStockDialog(context)
                            : ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to adjust stock'),
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Check if docId exists before showing Firestore view
    if (docId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          backgroundColor: Colors.blue[700],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [homeIconButton(context)],
        ),
        body: Center(
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
                  Icons.error_outline,
                  size: 64,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Item data not available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, show Firestore document view
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: docId != null
                ? () async {
                    final doc = await FirebaseFirestore.instance
                        .collection('inventory')
                        .doc(docId)
                        .get();
                    if (doc.exists && context.mounted) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(
                            documentId: docId!,
                            itemData: doc.data()!,
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item updated')),
                        );
                      }
                    }
                  }
                : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'quick_edit':
                  if (docId != null) {
                    final doc = await FirebaseFirestore.instance
                        .collection('inventory')
                        .doc(docId)
                        .get();
                    if (doc.exists && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(
                            documentId: docId!,
                            itemData: doc.data()!,
                          ),
                        ),
                      );
                    }
                  }
                  break;
                case 'adjust_stock':
                  _showAdjustStockDialog(context);
                  break;
                case 'delete':
                  _confirmDelete(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'quick_edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_note),
                    SizedBox(width: 8),
                    Text('Quick Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'adjust_stock',
                child: Row(
                  children: [
                    Icon(Icons.inventory),
                    SizedBox(width: 8),
                    Text('Adjust Stock'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Item', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          homeIconButton(context),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('inventory')
            .doc(docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading item details...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
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
                    'Item not found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final sapCode = data['sapCode']?.toString() ?? 'N/A';
          final name = (data['name']?.toString() ?? 'Unnamed Item').toUpperCase();
          final currentStock = (data['currentStock'] ?? 0) as int;
          final safetyLevel = (data['maxStock'] ?? 0) as int;
          final replenishQty = (data['replenishQty'] ?? 100) as int;
          final internalRef = ValidationService.validateInternalReference(data['internalRef']?.toString()) ?? (data['internalRef']?.toString() ?? '-');
          final description =
              data['description']?.toString() ?? 'No description available';
          final location = data['location']?.toString() ?? '-';
          final lastUpdated = data['lastUpdated'] as Timestamp?;
          final recentActivity =
              (data['recentActivity'] as List<dynamic>?) ?? [];
          final pictureUrl = data['pictureUrl']?.toString();

          final status = _getStockStatus(currentStock, safetyLevel);
          final statusColor = _getStatusColor(status);
          final statusIcon = _getStatusIcon(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Item Picture
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.blue[50],
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[700]! : Colors.blue[200]!,
                    ),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Picture
                          if (pictureUrl != null && pictureUrl.isNotEmpty)
                            Container(
                              width: 100,
                              height: 100,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  pictureUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 32,
                                        color: isDarkMode
                                            ? Colors.grey[600]
                                            : Colors.grey[400],
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
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
                              child: Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 32,
                                  color: isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SAP: $sapCode',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon,
                                          color: statusColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
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

                // Stock Information Section
                _buildDetailSection(
                  context,
                  title: 'Stock Information',
                  icon: Icons.bar_chart_outlined,
                  isDarkMode: isDarkMode,
                  children: [
                    _buildDetailRow(
                        'Actual Qty', currentStock.toString(), isDarkMode),
                    _buildDetailRow(
                        'Safety Level', safetyLevel.toString(), isDarkMode),
                    _buildDetailRow(
                        'Replenish Qty', replenishQty.toString(), isDarkMode),
                  ],
                ),
                const SizedBox(height: 20),

                // Item Details Section
                _buildDetailSection(
                  context,
                  title: 'Item Details',
                  icon: Icons.description_outlined,
                  isDarkMode: isDarkMode,
                  children: [
                    _buildDetailRow('Internal Ref', internalRef, isDarkMode),
                    _buildDetailRow('Location', location, isDarkMode),
                    _buildDetailRow(
                      'Last Updated',
                      lastUpdated != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(lastUpdated.toDate())
                          : 'N/A',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Activity Section
                _buildDetailSection(
                  context,
                  title: 'Recent Activity',
                  icon: Icons.history_outlined,
                  isDarkMode: isDarkMode,
                  children: [
                    if (recentActivity.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No recent activity',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: recentActivity.map<Widget>((activity) {
                          final activityStr = activity.toString();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    activityStr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Item'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: docId != null
                            ? () async {
                                final doc = await FirebaseFirestore.instance
                                    .collection('inventory')
                                    .doc(docId)
                                    .get();
                                if (doc.exists && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditItemScreen(
                                        documentId: docId!,
                                        itemData: doc.data()!,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Adjust Stock'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _showAdjustStockDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 20, color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[200] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    // Fetch current item data for display
    final docSnapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .doc(docId)
        .get();
    if (!docSnapshot.exists || !context.mounted) return;

    final data = docSnapshot.data()!;
    final name = (data['name']?.toString() ?? 'Unnamed Item').toUpperCase();
    final sapCode = data['sapCode']?.toString() ?? 'N/A';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Item?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'SAP: $sapCode',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to delete this item?',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will permanently remove it from the inventory and cannot be undone.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Delete photo from Firebase Storage if it exists
        final pictureUrl = data['pictureUrl']?.toString();
        if (pictureUrl != null && pictureUrl.isNotEmpty) {
          try {
            final storageRef = FirebaseStorage.instance.refFromURL(pictureUrl);
            await storageRef.delete();
          } catch (storageError) {
            // Continue with document deletion even if photo deletion fails
            debugPrint('Failed to delete photo: $storageError');
          }
        }

        // Delete Firestore document
        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(docId)
            .delete();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  void _showAdjustStockDialog(BuildContext context) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .doc(docId)
        .get();
    if (!docSnapshot.exists || !context.mounted) return;

    final data = docSnapshot.data()!;
    final currentStock = (data['currentStock'] ?? 0) as int;
    final maxStock = (data['maxStock'] ?? 0) as int;
    final replenishQty = (data['replenishQty'] ?? 100) as int;
    final name = (data['name']?.toString() ?? 'Item').toUpperCase();

    final maxStockController = TextEditingController(text: maxStock.toString());
    final replenishQtyController = TextEditingController(text: replenishQty.toString());
    final actualQuantityController = TextEditingController(text: currentStock.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        elevation: 0,
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Adjust Stock',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Stock Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(ctx).brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currentStock units',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form Fields
                    _buildStockInputField(
                      context: ctx,
                      controller: actualQuantityController,
                      label: 'Actual Quantity',
                      icon: Icons.inbox_outlined,
                      hint: 'Physical count of items',
                      description: 'Current physical quantity in stock',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStockInputField(
                      context: ctx,
                      controller: maxStockController,
                      label: 'Safety Level (Minimum)',
                      icon: Icons.shield_outlined,
                      hint: 'Minimum acceptable stock level',
                      description: 'Reorder when stock falls below this',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStockInputField(
                      context: ctx,
                      controller: replenishQtyController,
                      label: 'Replenish Quantity',
                      icon: Icons.add_box_outlined,
                      hint: 'Order quantity when restocking',
                      description: 'Amount to order when stock is low',
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(ctx).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx, true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Update Stock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && context.mounted) {
      try {
        final newMaxStock = int.tryParse(maxStockController.text) ?? maxStock;
        final newReplenishQty = int.tryParse(replenishQtyController.text) ?? replenishQty;
        final newActualQuantity = int.tryParse(actualQuantityController.text) ?? currentStock;

        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(docId)
            .update({
          'maxStock': newMaxStock,
          'replenishQty': newReplenishQty,
          'currentStock': newActualQuantity,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Dispose controllers before closing
        maxStockController.dispose();
        replenishQtyController.dispose();
        actualQuantityController.dispose();

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock adjusted successfully')),
          );
        }
      } catch (e) {
        maxStockController.dispose();
        replenishQtyController.dispose();
        actualQuantityController.dispose();

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Adjustment failed: $e')),
          );
        }
      }
    }
  }

  Widget _buildStockInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String description,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.numbers,
                color: Colors.blue[600],
                size: 18,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue[600]!,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}


