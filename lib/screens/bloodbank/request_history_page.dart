import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'fullhistory.dart';

const Color bloodRed = Color(0xFFB00020);

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    setState(() => isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('patient_requests')
        .select('*')
        .eq('bloodbank_id', userId)
        .eq('status', 'pending');

    final sorted = List<Map<String, dynamic>>.from(response)
      ..sort((a, b) {
        const priority = {'high': 0, 'medium': 1, 'low': 2};
        return (priority[a['urgency']] ?? 3)
            .compareTo(priority[b['urgency']] ?? 3);
      });

    setState(() {
      pendingRequests = sorted;
      isLoading = false;
    });
  }

  Future<void> updateRequestStatus(
    String requestId,
    String status, {
    DateTime? donationDate,
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{'status': status};

      if (status == 'accepted' && donationDate != null) {
        updates['accepted_donate_at'] = donationDate.toUtc().toIso8601String();
        updates['rejection_reason'] = null;
      } else if (status == 'rejected' && rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
        updates['accepted_donate_at'] = null;
      }

      await supabase
          .from('patient_requests')
          .update(updates)
          .eq('id', requestId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as $status')),
      );
      await fetchPendingRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  void showAcceptDialog(String requestId) {
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select donation date and time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: const Text('Pick Date & Time'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      setState(() {});
                    }
                  }
                },
              ),
              Text('Selected: ${selectedDate.toLocal()}'.split('.')[0]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                updateRequestStatus(
                  requestId,
                  'accepted',
                  donationDate: selectedDate,
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showRejectDialog(String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter rejection reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                updateRequestStatus(
                  requestId,
                  'rejected',
                  rejectionReason: reason,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason cannot be empty')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return isoString;
    }
  }

  Color getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return bloodRed;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        title: const Text('Pending Requests',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FullRequestHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bloodRed,
        child: const Icon(Icons.refresh, color: Colors.white),
        onPressed: fetchPendingRequests,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final r = pendingRequests[index];
                    final urgency = r['urgency'] ?? '';
                    final urgencyColor = getUrgencyColor(urgency);

                    return Card(
                      color: Colors.red.shade100,
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Blood Type: ${r['blood_type']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Units: ${r['requested_units']}'),
                            Text(
                              'Urgency: $urgency',
                              style: TextStyle(
                                color: urgencyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Requested At: ${_formatDate(r['request_time'])}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => showAcceptDialog(r['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: bloodRed),
                              onPressed: () => showRejectDialog(r['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
