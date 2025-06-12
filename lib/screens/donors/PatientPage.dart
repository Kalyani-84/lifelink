import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'requestpage.dart';

const Color bloodRed = Color(0xFF8B0000);

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> stockData = [];
  List<dynamic> filteredData = [];
  String searchQuery = "";
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchStockData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {}); // Rebuild
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchStockData() async {
    try {
      final data = await supabase.from('bloodbank_stock').select();
      setState(() {
        stockData = data;
        filteredData = stockData;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Error: $e');
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredData = stockData.where((item) {
        final bloodType = item['blood_type']?.toString().toLowerCase() ?? '';
        return bloodType.contains(query.toLowerCase());
      }).toList();
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bloodRed,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> showRequestDialog(Map item) async {
    final unitsController = TextEditingController();
    String selectedUrgency = 'low';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: bloodRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Request Blood",
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "From: ${item['name']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: unitsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Units",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    dropdownColor: bloodRed,
                    value: selectedUrgency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedUrgency = value);
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: "Urgency",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: ['low', 'medium', 'high'].map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(
                          level[0].toUpperCase() + level.substring(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: bloodRed,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    unitsController.dispose();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: bloodRed,
                  ),
                  onPressed: () async {
                    final units =
                        int.tryParse(unitsController.text.trim()) ?? 0;
                    final userId = supabase.auth.currentUser?.id;

                    if (userId == null) {
                      showSnackBar("User not logged in");
                      return;
                    }

                    if (units <= 0) {
                      showSnackBar("Enter valid units");
                      return;
                    }

                    if (item['bbid'] == null) {
                      showSnackBar("Missing blood bank ID");
                      return;
                    }

                    try {
                      await supabase.from('patient_requests').insert({
                        'patient_id': userId,
                        'bloodbank_id': item['bbid'],
                        'blood_type': item['blood_type'],
                        'requested_units': units,
                        'urgency': selectedUrgency,
                      });

                      if (!mounted) return;
                      Navigator.pop(context);
                      unitsController.dispose();
                      showSnackBar("Request sent successfully!");
                    } catch (e) {
                      if (!mounted) return;
                      showSnackBar('Failed: $e');
                    }
                  },
                  child: const Text("Send Request"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        title: const Text(
          "Find Blood Banks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: bloodRed,
          ),
        ),
        backgroundColor: const Color(0xFFFDF4F4),
        elevation: 0,
        foregroundColor: bloodRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "My Requests",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyRequestsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterSearch,
              decoration: InputDecoration(
                labelText: 'Search by Blood Type',
                filled: true,
                fillColor: Colors.red.shade50,
                prefixIcon: const Icon(Icons.search, color: bloodRed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: bloodRed),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredData.isEmpty
                ? const Center(child: Text("No stock data found"))
                : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: bloodRed.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: bloodRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("📍 ${item['location']}",
                                  style: const TextStyle(color: Colors.black)),
                              Text("🩸 Blood Type: ${item['blood_type']}",
                                  style: const TextStyle(color: Colors.black)),
                              Text("📦 Units: ${item['units']}",
                                  style: const TextStyle(color: Colors.black)),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: bloodRed,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => showRequestDialog(item),
                                  child: const Text("Request"),
                                ),
                              ),
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
