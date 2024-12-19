// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:bill_management/database_helper.dart';

class ViewBillScreen extends StatefulWidget {
  final Map<String, dynamic> bill;

  ViewBillScreen({required this.bill});

  @override
  _ViewBillScreenState createState() => _ViewBillScreenState();
}

class _ViewBillScreenState extends State<ViewBillScreen> {
  late bool isPaid;
  late Map<String, dynamic> bill; // Mutable copy of the bill
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    bill = Map.from(widget.bill); // Create a mutable copy of the bill
    isPaid = bill['isPaid'] == 1; // Initialize the toggle state
    _loadItems();
  }

  // Load items associated with the bill
  void _loadItems() async {
    final db = DatabaseHelper();
    final fetchedItems = await db.getItemsByBillId(bill['id']);
    setState(() {
      items = fetchedItems;
    });
  }

  // Toggle the payment status and update the database
  Future<void> _togglePaidStatus() async {
    // Toggle the status before updating the database
    bool updatedStatus = !isPaid;

    // Update the local state
    setState(() {
      isPaid = updatedStatus;
    });

    // Update the database
    final db = DatabaseHelper();
    await db.updateBillStatus(bill['id'], updatedStatus ? 1 : 0);

    // Update the local mutable copy of the bill
    bill['isPaid'] = updatedStatus ? 1 : 0;

    // Ensure the UI is updated before navigating back
    if (mounted) {
      Navigator.pop(context, bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name: ${bill['customerName']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Contact: ${bill['contactNumber']}'),
            SizedBox(height: 8),
            Divider(),
            Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['itemName']),
                    subtitle: Text('Price: ${item['unitPrice']}'),
                    trailing: Text('Quantity: ${item['quantity']}'),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Total Amount: ${bill['totalAmount']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${isPaid ? 'Paid' : 'Unpaid'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isPaid,
                  onChanged: (value) async {
                    await _togglePaidStatus();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
