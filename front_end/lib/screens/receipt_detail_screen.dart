import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Document document;

  const ReceiptDetailScreen({super.key, required this.document});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _deleteReceipt() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warning'),
        content: const Text('Are you sure you want to delete this receipt? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _apiService.deleteDocument(widget.document.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt deleted successfully')),
        );
        Navigator.pop(context, true); // Pop back to home with true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
        actions: [
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: doc.id != null ? _deleteReceipt : null,
              tooltip: 'Delete Receipt',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.receipt_long, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doc.merchantName ?? 'Unknown Merchant',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    doc.docDate ?? 'No date recorded',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    doc.totalAmount != null
                      ? NumberFormat.currency(symbol: '\$').format(doc.totalAmount)
                      : '\$0.00',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 48, thickness: 2),
            
            // Details Section
            const Text(
              'RAW DATA',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Currency', doc.currency),
            _buildDetailRow('Database ID', doc.id?.toString() ?? 'Pending'),
            if (doc.rawText != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Raw OCR Text', doc.rawText!),
            ],
            
            // Line Items Section 
            const SizedBox(height: 32),
            const Text(
              'LINE ITEMS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            if (doc.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No line items recorded.', style: TextStyle(fontStyle: FontStyle.italic)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doc.items.length,
                itemBuilder: (context, index) {
                  final item = doc.items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.itemName),
                    trailing: Text(
                      item.itemPrice != null
                          ? NumberFormat.currency(symbol: '\$').format(item.itemPrice)
                          : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
