import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'donor_request.dart';
import 'donorform.dart';

const Color bloodRed = Color(0xFFB00020);

class DonorRequestPage extends StatefulWidget {
  const DonorRequestPage({Key? key}) : super(key: key);

  @override
  State<DonorRequestPage> createState() => _DonorRequestPageState();
}

class _DonorRequestPageState extends State<DonorRequestPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() => loading = true);
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        requests = [];
        loading = false;
      });
      return;
    }

    try {
      final data = await supabase
          .from('request_to_donor')
          .select('*, bloodbank(name, location)')
          .eq('donor_id', user.id)
          .eq('request_status', 'pending')
          .order('request_sent_at', ascending: false);

      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: bloodRed,
          content: Text('Failed to fetch requests: $e'),
        ),
      );
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    String status, {
    DateTime? donationDate,
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{'request_status': status};
      if (status == 'accepted' && donationDate != null) {
        updates['accepted_donate_at'] = donationDate.toUtc().toIso8601String();
        updates['rejection_reason'] = null;
      } else if (status == 'rejected' && rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
        updates['accepted_donate_at'] = null;
      }

      await supabase
          .from('request_to_donor')
          .update(updates)
          .eq('id', requestId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: bloodRed,
          content: Text('Request marked as ${status.toUpperCase()}'),
        ),
      );
      await fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: bloodRed,
          content: Text('Failed to update request: $e'),
        ),
      );
    }
  }

  void showAcceptDialog(String requestId) {
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bloodRed,
          title: const Text(
            'Select Donation Date & Time',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text('Pick Date & Time',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2)),
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
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
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
              const SizedBox(height: 8),
              Text(
                'Selected: ${selectedDate.toLocal()}'.split('.')[0],
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                updateRequestStatus(requestId, 'accepted',
                    donationDate: selectedDate);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void showRejectDialog(String requestId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bloodRed,
          title: const Text(
            'Reject Request',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.pop(context);
                  updateRequestStatus(requestId, 'rejected',
                      rejectionReason: reason);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: bloodRed,
                      content: Text('Reason is required'),
                    ),
                  );
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget requestCard(Map<String, dynamic> req) {
    final bloodbank = req['bloodbank'] ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bloodRed.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request from: ${bloodbank['name'] ?? 'Unknown'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '📍 Location: ${bloodbank['location'] ?? 'Unknown'}',
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text('Accept',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  onPressed: () => showAcceptDialog(req['id']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: const Text('Reject',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bloodRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  onPressed: () => showRejectDialog(req['id']),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        title: const Text(
          'My Blood Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: bloodRed,
          ),
        ),
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
                    builder: (_) => const DonorRequestHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) => requestCard(requests[index]),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bloodRed,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DonorFormPage()),
          );
        },
        tooltip: 'Check Eligibility',
        child: const Icon(Icons.add),
      ),
    );
  }
}
