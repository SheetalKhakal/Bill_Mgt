// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables

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

  int invoiceNumber = 1;

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
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final newBill = {
        'customerName': customerName,
        'contactNumber': contactNumber,
        'totalAmount': totalAmount,
        'isPaid': 0,
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

      Navigator.pop(context, true);
    }
  }

  void _fetchInvoiceNumber() async {
    final db = DatabaseHelper();
    final lastInvoiceId = await db.getLastInvoiceId();

    setState(() {
      if (lastInvoiceId is int) {
        invoiceNumber = lastInvoiceId + 1;
      } else {
        invoiceNumber = 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchInvoiceNumber();
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('Generate Invoice')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice No.',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Invoice Date',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$invoiceNumber',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentDate,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(labelText: 'Customer Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                        controller: _contactNumberController,
                        decoration:
                            InputDecoration(labelText: 'Contact Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          } else if (value.length != 10 ||
                              !RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Enter a valid 10-digit contact number.';
                          }
                          return null;
                        }),
                  ],
                ),
              ),
              Text(
                'Product Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _itemNameController,
                            decoration: InputDecoration(labelText: 'Item Name'),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _unitPriceController,
                            decoration:
                                InputDecoration(labelText: 'Unit Price'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: _addItem,
                  child: Text('Add Product'),
                ),
              ),
              Divider(),
              items.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Product',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _itemNameController.text =
                                              item['itemName'];
                                          _quantityController.text =
                                              item['quantity'].toString();
                                          _unitPriceController.text =
                                              item['unitPrice'].toString();
                                          setState(() {
                                            totalAmount -= item['totalPrice'];
                                            items.removeAt(index);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            totalAmount -= item['totalPrice'];
                                            items.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['itemName']}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    '${item['quantity']} x ₹${item['unitPrice'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    '₹${item['totalPrice'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: _saveBill,
                  child: Text('Save Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
