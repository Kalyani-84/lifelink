import 'package:flutter/material.dart';
import 'package:lifelink/screens/bloodbank/fullhistory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonorRequestHistoryPage extends StatefulWidget {
  const DonorRequestHistoryPage({super.key});

  @override
  State<DonorRequestHistoryPage> createState() =>
      _DonorRequestHistoryPageState();
}

class _DonorRequestHistoryPageState extends State<DonorRequestHistoryPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  String bloodbankId = '';
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not logged in")));
      return;
    }

    bloodbankId = user.id;

    try {
      setState(() => loading = true);

      // Include additional donor fields in the select
      final data = await supabase
          .from('request_to_donor')
          .select('''
            *, 
            donor_predictions(
              name, 
              blood_group,
              age,
              gender,
              medical_history,
              location
            )
            ''')
          .eq('bloodbank_id', bloodbankId)
          .order('request_sent_at', ascending: false);

      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      print('Error loading request history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load request history: $e')),
      );
      setState(() => loading = false);
    }
  }

  Widget buildStatusWidget(Map<String, dynamic> request) {
    final status = request['request_status'];
    final acceptAt = request['accepted_donate_at'];
    final rejectReason = request['rejection_reason'];

    if (status == null) {
      return const Text('No status');
    }

    if (status.toString().toLowerCase() == 'accepted') {
      final dt = DateTime.tryParse(acceptAt ?? '');
      return Text(
        dt != null
            ? '✅ Accepted\n${dt.day}/${dt.month} @ ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
            : '✅ Accepted',
        style: const TextStyle(color: Colors.green),
      );
    } else if (status.toString().toLowerCase() == 'rejected') {
      return Text(
        '❌ Rejected\nReason: ${rejectReason ?? "N/A"}',
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return const Text('⏳ Pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
      ),
      backgroundColor: const Color(0xFFFDF4F4),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No requests found.'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final donor = request['donor_predictions'] ?? {};
                    return Card(
                      color: Colors.red.shade100,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(donor['name'] ?? 'Donor'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🩸 Blood Group: ${donor['blood_group'] ?? 'Unknown'}',
                            ),
                            Text(
                              '🎂 Age: ${donor['age']?.toString() ?? 'Unknown'}',
                            ),
                            Text('⚧ Gender: ${donor['gender'] ?? 'Unknown'}'),
                            Text(
                              '📍 Location: ${donor['location'] ?? 'Unknown'}',
                            ),
                            Text(
                              '📝 Medical History: ${donor['medical_history'] ?? 'None'}',
                            ),
                          ],
                        ),
                        trailing: buildStatusWidget(request),
                      ),
                    );
                  },
                ),
    );
  }
}
