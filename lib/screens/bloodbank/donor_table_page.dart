import 'package:flutter/material.dart';
import 'package:lifelink/screens/bloodbank/fullhistory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'donor_page.dart'; // import the new page

class DonorListPage extends StatefulWidget {
  const DonorListPage({super.key});

  @override
  State<DonorListPage> createState() => _DonorListPageState();
}

class _DonorListPageState extends State<DonorListPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  String bloodbankId = '';
  List<Map<String, dynamic>> donors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not logged in")));
      return;
    }

    bloodbankId = user.id;
    await fetchDonors();
  }

  Future<void> fetchDonors() async {
    setState(() => loading = true);

    try {
      // Fetch donor details including additional info
      final data = await supabase
          .from('donor_predictions')
          .select(
            'donor_id, user_id, name, blood_group, eligible, created_at, location, age, gender, medical_history',
          )
          .eq('eligible', true)
          .order('created_at', ascending: false);

      for (var donor in data) {
        final donorId = donor['user_id']; // actual donor UUID

        // Check if a request already exists for this donor and bloodbank
        final req = await supabase
            .from('request_to_donor')
            .select()
            .eq('donor_id', donorId)
            .eq('bloodbank_id', bloodbankId)
            .order('request_sent_at', ascending: false)
            .limit(1);

        donor['has_request'] = req.isNotEmpty;
      }

      setState(() {
        donors = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      print("Fetch error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch donors: $e")));
      setState(() => loading = false);
    }
  }

  Future<void> sendRequest(String donorId, String donorPredictionId) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sending request...')));

      print(
        'Sending request to donor_id: $donorId, donor_prediction_id: $donorPredictionId, bloodbank_id: $bloodbankId',
      );

      final response = await supabase.from('request_to_donor').insert({
        'donor_id': donorId,
        'donor_prediction_id': donorPredictionId,
        'bloodbank_id': bloodbankId,
        'request_status': 'pending',
        'request_message': 'We request your blood donation.',
        'request_sent_at': DateTime.now().toIso8601String(),
      });

      print('Insert response: $response');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent')));

      await fetchDonors();
    } catch (e) {
      print('Insert error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    }
  }

  Widget buildStatusWidget(Map<String, dynamic> donor) {
    final hasRequest = donor['has_request'] ?? false;

    if (!hasRequest) {
      return ElevatedButton(
        onPressed: () => sendRequest(
          donor['user_id'], // donor_id (actual donor UUID)
          donor['donor_id'], // donor_prediction_id (prediction UUID)
        ),
        child: const Text('Request'),
      );
    } else {
      // Request exists, show Re-request button only
      return ElevatedButton(
        onPressed: () => sendRequest(donor['user_id'], donor['donor_id']),
        style: ElevatedButton.styleFrom(backgroundColor: bloodRed),
        child: const Text(
          'Re-request',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligible Donors',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Request History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonorRequestHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF4F4),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : donors.isEmpty
              ? const Center(child: Text('No eligible donors found.'))
              : ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
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
                              '📝 Medical History: ${donor['medical_history'] ?? 'None'}',
                            ),
                            Text(
                              '📍 Location: ${donor['location'] ?? 'Unknown'}',
                            ),
                          ],
                        ),
                        trailing: buildStatusWidget(donor),
                      ),
                    );
                  },
                ),
    );
  }
}
