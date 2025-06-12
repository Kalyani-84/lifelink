import 'package:flutter/material.dart';
import 'package:lifelink/screens/donors/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRequestsPage extends StatelessWidget {
  MyRequestsPage({super.key});

  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMyRequests() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase.from('patient_requests').select('''
      *,
      bloodbank: bloodbank_stock (
        name,
        contact
      )
    ''').eq('patient_id', userId).order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void _callContact(String? contact) async {
    if (contact == null || contact.isEmpty) return;
    final uri = Uri.parse('tel:$contact');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        title: const Text("My Blood Requests"),
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
        elevation: 0,
      ),
      body: Column(
        children: [
          Divider(
            height: 2,
            thickness: 2,
            color: bloodRed,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMyRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No requests made yet."));
                }

                final requests = snapshot.data!;
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final bloodbank = req['bloodbank'] ?? {};
                    final bloodbankName =
                        bloodbank['name'] ?? 'Unknown Blood Bank';
                    final contact = bloodbank['contact']?.toString() ?? '';
                    final createdAt = req['created_at'] != null
                        ? DateTime.parse(req['created_at'])
                        : null;
                    final formattedTime = createdAt != null
                        ? dateFormat.format(createdAt)
                        : 'N/A';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bloodbankName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text("Requested at: $formattedTime"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.bloodtype,
                                  size: 16, color: Colors.red),
                              const SizedBox(width: 6),
                              Text("Blood Type: ${req['blood_type']}"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.opacity,
                                  size: 16, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text("Units: ${req['requested_units']}"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _callContact(contact),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bloodRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              icon: const Icon(Icons.call),
                              label: const Text("Call Blood Bank"),
                            ),
                          ),
                        ],
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
