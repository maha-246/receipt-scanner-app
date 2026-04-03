import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers to grab the text the user types into the input fields
  final _merchantNameController = TextEditingController();
  final _docDateController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');

  // List to hold our dynamic line items
  final List<LineItem> _lineItems = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _merchantNameController.dispose();
    _docDateController.dispose();
    _totalAmountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _showAddLineItemDialog() {
    final itemNameController = TextEditingController();
    final itemPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Line Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: itemPriceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (itemNameController.text.isNotEmpty) {
                setState(() {
                  _lineItems.add(LineItem(
                    itemName: itemNameController.text,
                    itemPrice: double.tryParse(itemPriceController.text),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('ADD ITEM'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    // Validate runs all the logic in the 'validator' blocks below
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading spinner
      });

      // Construct a new Document from the form fields
      final newDoc = Document(
        merchantName: _merchantNameController.text,
        docDate: _docDateController.text.isNotEmpty ? _docDateController.text : null,
        totalAmount: double.tryParse(_totalAmountController.text),
        currency: _currencyController.text,
        docType: 'receipt', // Enforced by your backend schema
        items: _lineItems, // Attach our list of line items!
      );

      try {
        await _apiService.createDocument(newDoc);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt successfully added!')),
          );
          // Return to previous screen, passing 'true' so the Home Screen knows to refresh the list
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save receipt: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data Manually'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _merchantNameController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => 
                    (value == null || value.isEmpty) ? 'Please enter a merchant name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _docDateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _totalAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Total Amount *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an amount';
                        if (double.tryParse(value) == null) return 'Must be a valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _currencyController,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              
              // NEW SECTION: Line Items
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Line Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddLineItemDialog,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Item'),
                  )
                ],
              ),
              const Divider(thickness: 2),
              
              if (_lineItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No items added yet.', style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Important when nesting inside SingleChildScrollView
                  itemCount: _lineItems.length,
                  itemBuilder: (context, index) {
                    final item = _lineItems[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.itemName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.itemPrice != null 
                              ? NumberFormat.currency(symbol: '\$').format(item.itemPrice)
                              : '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                _lineItems.removeAt(index);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
                
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SAVE RECEIPT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
