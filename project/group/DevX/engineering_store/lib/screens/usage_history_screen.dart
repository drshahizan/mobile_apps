import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../widgets/home_action.dart';

class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  String _selectedFilter = 'All'; // All, Receiving, Issuance
  int _receivingLimit = 20;
  int _issuanceLimit = 20;
  final int _pageStep = 20;
  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage History'),
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [homeIconButton(context)],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterButton(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: 'Receiving',
                  isSelected: _selectedFilter == 'Receiving',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'Receiving';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: 'Issuance',
                  isSelected: _selectedFilter == 'Issuance',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'Issuance';
                    });
                  },
                ),
              ],
            ),
          ),

          // Usage Logs List from Firebase
          Expanded(
            child: StreamBuilder<_UsageLogsResult>(
              stream: _getUsageLogsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final result = snapshot.data ?? _UsageLogsResult.empty();
                final filteredLogs = _selectedFilter == 'All'
                  ? result.logs
                  : result.logs
                    .where((log) => log.type == _selectedFilter)
                    .toList();

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No usage history found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLogs.length + (result.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= filteredLogs.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: _loadingMore
                              ? const CircularProgressIndicator()
                              : OutlinedButton(
                                  onPressed: _loadMore,
                                  child: const Text('Load more'),
                                ),
                        ),
                      );
                    }

                    final log = filteredLogs[index];
                    final isReceiving = log.type == 'Receiving';
                    final typeColor =
                        isReceiving ? Colors.green[600] : Colors.orange[600];
                    final typeIcon = isReceiving ? '📥' : '📤';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Type, Item Name, Quantity
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Type Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: typeColor?.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: typeColor ?? Colors.grey,
                                          ),
                                        ),
                                        child: Text(
                                          '$typeIcon ${log.type}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: typeColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Item Name
                                      Text(
                                        log.itemName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${log.quantity}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: typeColor,
                                      ),
                                    ),
                                    Text(
                                      'units',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Divider
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            // Details: SAP Code, Date, User, Remarks
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SAP: ${log.sapCode}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'User: ${log.user}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (log.remarks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Remarks: ${log.remarks}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
    );
  }

  Stream<_UsageLogsResult> _getUsageLogsStream() {
    final receivingStream = FirebaseFirestore.instance
        .collection('receivings')
        .orderBy('timestamp', descending: true)
        .limit(_receivingLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    final issuanceStream = FirebaseFirestore.instance
        .collection('issuance')
        .orderBy('timestamp', descending: true)
        .limit(_issuanceLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return Rx.combineLatest2(receivingStream, issuanceStream,
        (List<QueryDocumentSnapshot> receivingDocs,
            List<QueryDocumentSnapshot> issuanceDocs) {
      final receivingLogs = receivingDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final dateStr = timestamp != null
            ? '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
            : 'N/A';

        return UsageLog(
          id: doc.id,
          type: 'Receiving',
          itemName: data['itemName'] ?? 'Unknown',
          sapCode: data['sapCode'] ?? 'N/A',
          quantity: (data['quantityReceived'] as num?)?.toInt() ?? 0,
          date: dateStr,
          user: data['supplier'] ?? 'Unknown',
          remarks: data['remarks'] ?? '',
          timestamp: timestamp,
        );
      }).toList();

      final issuanceLogs = issuanceDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final dateStr = timestamp != null
            ? '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
            : 'N/A';

        return UsageLog(
          id: doc.id,
          type: 'Issuance',
          itemName: data['itemName'] ?? 'Unknown',
          sapCode: data['sapCode'] ?? 'N/A',
          quantity: (data['quantityIssued'] as num?)?.toInt() ?? 0,
          date: dateStr,
          user: data['technicianName'] ?? 'Unknown',
          remarks: data['usageLocation'] ?? '',
          timestamp: timestamp,
        );
      }).toList();

      final allLogs = [...receivingLogs, ...issuanceLogs];
      allLogs.sort((a, b) {
        if (a.timestamp == null || b.timestamp == null) return 0;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      final hasMore =
          receivingDocs.length == _receivingLimit || issuanceDocs.length == _issuanceLimit;
      return _UsageLogsResult(logs: allLogs, hasMore: hasMore);
    });
  }

  void _loadMore() {
    if (_loadingMore) return;
    setState(() {
      _loadingMore = true;
      _receivingLimit += _pageStep;
      _issuanceLimit += _pageStep;
    });
    // Allow button to re-enable after limits update and stream refreshes.
    Future.microtask(() => mounted ? setState(() => _loadingMore = false) : null);
  }
}

// Usage Log Model
class UsageLog {
  final String id;
  final String type; // 'Receiving' or 'Issuance'
  final String itemName;
  final String sapCode;
  final int quantity;
  final String date;
  final String user;
  final String remarks;
  final DateTime? timestamp;

  UsageLog({
    required this.id,
    required this.type,
    required this.itemName,
    required this.sapCode,
    required this.quantity,
    required this.date,
    required this.user,
    required this.remarks,
    this.timestamp,
  });
}

class _UsageLogsResult {
  final List<UsageLog> logs;
  final bool hasMore;

  _UsageLogsResult({required this.logs, required this.hasMore});

  factory _UsageLogsResult.empty() => _UsageLogsResult(logs: const [], hasMore: false);
}

// Filter Button Widget
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[800] : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.blue[800],
          side: BorderSide(
            color: isSelected ? Colors.blue[800]! : Colors.blue[300]!,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }
}
