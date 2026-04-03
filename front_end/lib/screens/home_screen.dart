import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'add_receipt_screen.dart';
import 'receipt_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Document>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  void _refreshDocuments() {
    setState(() {
      _documentsFuture = _apiService.fetchDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDocuments,
            tooltip: 'Refresh receipts',
          ),
        ],
      ),
      body: FutureBuilder<List<Document>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While we wait for the FastAPI backend to respond
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If the connection to backend fails
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error connecting to backend:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If connection succeeds but table is empty
            return const Center(child: Text('No receipts found. Try adding one!'));
          }

          // We got data successfully
          final documents = snapshot.data!;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptDetailScreen(document: doc),
                      ),
                    );
                    if (result == true) { // If it was deleted, refresh!
                      _refreshDocuments();
                    }
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amber, // Yellow accent
                    child: Icon(Icons.receipt, color: Colors.black87),
                  ),
                  title: Text(
                    doc.merchantName ?? 'Unknown Merchant',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(doc.docDate ?? 'No date'),
                  trailing: Text(
                    doc.totalAmount != null
                        // Uses the intl package to format to currency!
                        ? NumberFormat.currency(symbol: '\$').format(doc.totalAmount)
                        : '-',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the form
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReceiptScreen()),
          );
          
          // If the form passes back 'true', it means a receipt was successfully saved!
          if (result == true) {
             _refreshDocuments(); // Re-fetch the data to show the new receipt!
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
