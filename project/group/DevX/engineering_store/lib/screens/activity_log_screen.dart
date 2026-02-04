import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/home_action.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<QueryDocumentSnapshot> _logs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 20;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchLogs(reset: true);
  }

  Future<void> _fetchLogs({bool reset = false}) async {
    if (_isLoading) return;
    
    if (reset) {
      setState(() {
        _isLoading = true;
        _logs.clear();
        _lastDoc = null;
        _hasMore = true;
      });
    } else {
      if (!_hasMore) return;
      setState(() => _isLoading = true);
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('activity_logs')
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);

      if (_selectedFilter != 'All') {
        query = query.where('action', isEqualTo: _selectedFilter);
      }

      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        if (mounted) {
          setState(() {
            _logs.addAll(snap.docs);
          });
        }
      }

      if (snap.docs.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    await _fetchLogs(reset: true);
  }

  void _onFilterChanged(String label) {
    if (_selectedFilter == label) return;
    setState(() => _selectedFilter = label);
    _fetchLogs(reset: true);
  }

  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 24),
            const SizedBox(width: 8),
            const Text('Activity Logs'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          homeIconButton(context),
        ],
      ),
      body: Column(
        children: [
          // Header Info Bar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
                    'Track all user activities and system changes',
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by user email or action...',
                prefixIcon: const Icon(Icons.search),
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
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFilterDropdown(),
          ),
          const SizedBox(height: 12),
          // Activity Logs from Firebase (paged)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _logs.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No activity logs yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _logs.length + (_hasMore && !_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _logs.length) {
                              if (!_isLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _fetchLogs();
                                });
                              }
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final log = _logs[index];
                            final data = log.data() as Map<String, dynamic>;
                            
                            // Filter by search query
                            final userEmail = (data['userEmail'] ?? '').toString().toLowerCase();
                            final action = (data['action'] ?? '').toString().toLowerCase();
                            
                            if (_searchQuery.isNotEmpty && 
                                !userEmail.contains(_searchQuery) && 
                                !action.contains(_searchQuery)) {
                              return const SizedBox.shrink();
                            }

                            return _buildActivityLogItem(data, isDarkMode);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    const filterOptions = [
      'All',
      'SCREEN_ACCESS',
      'CHANGE_USER_ROLE',
      'ADD_ITEM',
      'EDIT_ITEM',
      'DELETE_ITEM',
      'RECEIVE_ITEM',
      'ISSUE_ITEM',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue[600]!,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedFilter,
        isExpanded: true,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _onFilterChanged(newValue);
          }
        },
        items: filterOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              _formatFilterLabel(value),
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatFilterLabel(String label) {
    if (label == 'All') return 'All';
    // Convert SNAKE_CASE to Title Case
    return label.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildActivityLogItem(Map<String, dynamic> data, bool isDarkMode) {
    final action = data['action'] ?? 'UNKNOWN';
    final screenName = data['screenName'] ?? 'Unknown Screen';
    final userEmail = data['userEmail'] ?? 'Unknown User';
    final userRole = data['userRole'] ?? 'N/A';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final details = data['details'] as Map<String, dynamic>?;
    final changes = data['changes'] as Map<String, dynamic>?;
    
    // Format timestamp
    final timeStr = timestamp != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp)
        : 'N/A';
    
    // Determine icon and color based on action
    IconData icon;
    Color color;
    
    switch (action) {
      case 'SCREEN_ACCESS':
        icon = Icons.remove_red_eye;
        color = Colors.blue;
        break;
      case 'ADD_ITEM':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'EDIT_ITEM':
        icon = Icons.edit;
        color = Colors.orange;
        break;
      case 'DELETE_ITEM':
        icon = Icons.delete;
        color = Colors.red;
        break;
      case 'RECEIVE_ITEM':
        icon = Icons.arrow_downward;
        color = Colors.teal;
        break;
      case 'ISSUE_ITEM':
        icon = Icons.arrow_upward;
        color = Colors.purple;
        break;
      case 'RECORD_USAGE':
        icon = Icons.history;
        color = Colors.indigo;
        break;
      case 'CHANGE_USER_ROLE':
        icon = Icons.admin_panel_settings;
        color = Colors.deepOrange;
        break;
      case 'USER_LOGIN':
        icon = Icons.login;
        color = Colors.green[700]!;
        break;
      case 'USER_LOGOUT':
        icon = Icons.logout;
        color = Colors.grey;
        break;
      case 'ADD_LOCATION':
        icon = Icons.add_location;
        color = Colors.cyan;
        break;
      case 'EDIT_LOCATION':
        icon = Icons.edit_location;
        color = Colors.amber;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatActionTitle(action),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      screenName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.person, '$userEmail ($userRole)', isDarkMode),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, timeStr, isDarkMode),
          
          // Show details if available
          if (details != null && details.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 6),
            ...details.entries.map((entry) {
              if (entry.key == 'itemData' || entry.key == 'locationData') {
                return const SizedBox.shrink(); // Skip complex nested data
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_formatKey(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ],
          
          // Show changes if available
          if (changes != null && changes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Changes:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.amber[200] : Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...changes.entries.map((entry) {
                    final change = entry.value as Map<String, dynamic>?;
                    if (change != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${_formatKey(entry.key)}: ${change['old']} → ${change['new']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  String _formatActionTitle(String action) {
    return action.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatKey(String key) {
    return key.split(RegExp(r'(?=[A-Z])|_')).map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
