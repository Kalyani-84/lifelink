import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color bloodRed = Color(0xFFB00020);

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> stockList = [];
  bool loading = true;

  final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    fetchStock();
  }

  Future<void> fetchStock() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('stock')
          .select('*')
          .eq('bank_id', userId as Object)
          .order('timestamp', ascending: false);

      debugPrint('👉 Stock Response: $response');

      setState(() {
        stockList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('❗ Error fetching stock: $e');
      _showSnackbar('Error fetching stock');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addOrUpdateStock({
    String? id,
    required String bloodType,
    required int units,
  }) async {
    try {
      if (id == null) {
        await supabase.from('stock').insert({
          'bank_id': supabase.auth.currentUser?.id as Object,
          'blood_type': bloodType,
          'units': units,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _showSnackbar('Stock added successfully!');
      } else {
        await supabase.from('stock').update({
          'units': units,
          'timestamp': DateTime.now().toIso8601String(),
        }).eq('id', id);
        _showSnackbar('Stock updated successfully!');
      }
      fetchStock();
    } catch (e) {
      debugPrint('❗ Error saving stock: $e');
      _showSnackbar('Error saving stock');
    }
  }

  Future<void> deleteStock(String id) async {
    try {
      await supabase.from('stock').delete().eq('id', id);
      _showSnackbar('Stock deleted');
      fetchStock();
    } catch (e) {
      debugPrint('❗ Error deleting stock: $e');
      _showSnackbar('Error deleting stock');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bloodRed,
      ),
    );
  }

  void showStockDialog({Map<String, dynamic>? stock}) {
    final TextEditingController unitController = TextEditingController(
      text: stock != null ? stock['units'].toString() : '',
    );
    String selectedType = stock?['blood_type'] ?? bloodTypes.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          stock != null ? 'Update Stock' : 'Add Stock',
          style: const TextStyle(color: bloodRed),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              items: bloodTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
              decoration: const InputDecoration(labelText: 'Blood Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Units'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bloodRed),
            onPressed: () {
              final units = int.tryParse(unitController.text);
              if (units != null) {
                addOrUpdateStock(
                  id: stock?['id'],
                  bloodType: selectedType,
                  units: units,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
        title: const Text('Stock Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: const Color(0xFFFDF4F4),
        foregroundColor: bloodRed,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchStock),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bloodRed,
        onPressed: () => showStockDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: bloodRed))
          : stockList.isEmpty
              ? const Center(
                  child: Text('No stock available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: stockList.length,
                  itemBuilder: (context, index) {
                    final stock = stockList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.red.shade100,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: bloodRed,
                            child: Text(
                              stock['blood_type'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            'Blood Type: ${stock['blood_type']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Available Units: ${stock['units']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: bloodRed),
                                onPressed: () => showStockDialog(stock: stock),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: bloodRed),
                                onPressed: () =>
                                    deleteStock(stock['id'].toString()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
