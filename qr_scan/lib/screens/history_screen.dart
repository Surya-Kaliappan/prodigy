import 'package:flutter/material.dart';
import 'package:qr_scan/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<String>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _getHistory();
  }

  Future<List<String>> _getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('scan_history') ?? [];
  }

  Future<void> _deleteScan(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('scan_history') ?? [];
    history.removeAt(index);
    await prefs.setStringList('scan_history', history);
    // Refresh the UI by re-fetching the history
    setState(() {
      _historyFuture = _getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History'), centerTitle: true),
      body: FutureBuilder<List<String>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading history."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No scans found."));
          }

          final scans = snapshot.data!;
          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final code = scans[index];
              final bool isUrl = Uri.tryParse(code)?.isAbsolute ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(isUrl ? Icons.link : Icons.text_fields),
                  title: Text(
                    code,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteScan(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResultScreen(scannedCode: code, onClose: () {}),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
