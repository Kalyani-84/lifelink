import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Define bloodRed color if not already imported
const Color bloodRed = Color(0xFFB00020);

class FullRequestHistoryPage extends StatefulWidget {
  const FullRequestHistoryPage({super.key});

  @override
  FullRequestHistoryPageState createState() => FullRequestHistoryPageState();
}

class FullRequestHistoryPageState extends State<FullRequestHistoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequestHistory();
  }

  Future<void> fetchRequestHistory() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('User not logged in');
        return;
      }

      final response = await supabase
          .from('patient_requests')
          .select('*')
          .eq('bloodbank_id', userId)
          .not('status', 'eq', 'pending'); // Only accepted/rejected

      final sorted = List<Map<String, dynamic>>.from(response)
        ..sort((a, b) {
          const priority = {'high': 0, 'medium': 1, 'low': 2};
          return (priority[a['urgency']] ?? 3).compareTo(
            priority[b['urgency']] ?? 3,
          );
        });

      setState(() {
        requests = sorted;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      setState(() => isLoading = false);
    }
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

  Color _urgencyColor(String urgency) {
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
      appBar: AppBar(
        title: const Text('Accepted / Rejected Requests'),
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
      ),
      backgroundColor: const Color(0xFFFDF4F4),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bloodRed,
        child: const Icon(Icons.refresh, color: Colors.white),
        onPressed: fetchRequestHistory,
      ),
      body: Column(
        children: [
          const Divider(
            color: bloodRed,
            thickness: 2,
            height: 2,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                      ? const Center(
                          child:
                              Text('No accepted or rejected requests found.'))
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final r = requests[index];
                            final urgency = r['urgency'] ?? 'unknown';

                            return Card(
                              color: Colors.red.shade100,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  'Blood Type: ${r['blood_type']}',
                                  style: TextStyle(
                                    color: urgency.toLowerCase() == 'high'
                                        ? Colors.red
                                        : null,
                                    fontWeight: urgency.toLowerCase() == 'high'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Units: ${r['requested_units']}'),
                                    Text(
                                      'Urgency: $urgency',
                                      style: TextStyle(
                                        color: _urgencyColor(urgency),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                        'Requested At: ${_formatDate(r['request_time'])}'),
                                    Text('Status: ${r['status']}'),
                                    if (r['rejection_reason'] != null)
                                      Text('Reason: ${r['rejection_reason']}'),
                                    if (r['accepted_donate_at'] != null)
                                      Text(
                                          'Donation At: ${_formatDate(r['accepted_donate_at'])}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
