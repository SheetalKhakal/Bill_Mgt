// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:bill_management/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateBillScreen extends StatefulWidget {
  @override
  _CreateBillScreenState createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  List<Map<String, dynamic>> items = [];
  double totalAmount = 0.0;

  void _addItem() {
    final itemName = _itemNameController.text.trim();
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;

    if (itemName.isNotEmpty && quantity > 0 && unitPrice > 0) {
      setState(() {
        items.add({
          'itemName': itemName,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'totalPrice': quantity * unitPrice,
        });
        totalAmount += quantity * unitPrice;
      });

      _itemNameController.clear();
      _quantityController.clear();
      _unitPriceController.clear();
    }
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState!.validate()) {
      final customerName = _customerNameController.text.trim();
      final contactNumber = _contactNumberController.text.trim();
      final date = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.now()); // Properly formatted date

      final newBill = {
        'customerName': customerName,
        'contactNumber': contactNumber,
        'totalAmount': totalAmount,
        'isPaid': 0, // Default to unpaid
        'date': date,
      };

      final db = DatabaseHelper();
      final billId = await db.insertBill(newBill);

      for (var item in items) {
        final newItem = {
          'billId': billId,
          'itemName': item['itemName'],
          'quantity': item['quantity'],
          'unitPrice': item['unitPrice'],
        };
        await db.insertItem(newItem);
      }

      Navigator.pop(context, true); // Pass true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Bill')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              Divider(),
              Text(
                'Add Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('Add Item'),
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text('${item['itemName']}'),
                    subtitle: Text(
                        '${item['quantity']} x \$${item['unitPrice'].toStringAsFixed(2)}'),
                    trailing: Text(
                        'Total: \$${item['totalPrice'].toStringAsFixed(2)}'),
                  );
                },
              ),
              Divider(),
              Text(
                'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBill,
                child: Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
