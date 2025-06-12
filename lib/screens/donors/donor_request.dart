import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    fetchRequestHistory();
  }

  Future<void> fetchRequestHistory() async {
    setState(() => loading = true);
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('User not logged in');
      return;
    }

    try {
      final data = await supabase
          .from('request_to_donor')
          .select('*, bloodbank(bbid, name, location)')
          .eq('donor_id', user.id)
          .order('request_sent_at', ascending: false);

      debugPrint('Fetched: $data');

      setState(() {
        history = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => loading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'pending':
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFDF4F4);
    const Color bloodRed = Color(0xFF8B0000);
    ;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: bloodRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donor Request History',
          style: TextStyle(
            color: bloodRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(
            color: bloodRed,
            thickness: 1.5,
            height: 1,
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? const Center(child: Text('No request history.'))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final req = history[index];
                          final bloodbank = req['bloodbank'] ?? {};
                          final donationDate = req['accepted_donate_at'] != null
                              ? DateTime.tryParse(req['accepted_donate_at'])
                              : null;

                          return Card(
                            color: getStatusColor(req['request_status']),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                'From: ${bloodbank['name'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '📍 ${bloodbank['location'] ?? 'Unknown'}'),
                                  Text('Status: ${req['request_status']}'),
                                  if (donationDate != null)
                                    Text(
                                      'Donation At: ${donationDate.toLocal().toString().split(".")[0]}',
                                    ),
                                  if (req['rejection_reason'] != null)
                                    Text('Reason: ${req['rejection_reason']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
