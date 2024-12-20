// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:bill_management/database_helper.dart';
import 'package:bill_management/screens/create_bill_screen.dart';
import 'package:bill_management/screens/view_bill_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() async {
    final db = DatabaseHelper();
    final fetchedBills = await db.getBills();
    setState(() {
      bills =
          List<Map<String, dynamic>>.from(fetchedBills); // Ensure mutability
    });
  }

  void _removeBillFromList(int billId) {
    setState(() {
      bills.removeWhere((bill) => bill['id'] == billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill Management')),
      body: ListView.builder(
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return ListTile(
            title: Text(bill['customerName']),
            subtitle:
                Text('Total: ₹${bill['totalAmount']}   - ${bill['date']}'),
            trailing: Text(
              bill['isPaid'] == 1 ? 'Paid' : 'Unpaid',
              style: TextStyle(
                color: bill['isPaid'] == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewBillScreen(bill: bill),
                ),
              );

              if (result == 'deleted') {
                _removeBillFromList(bill['id']);
              } else if (result != null) {
                setState(() {
                  final index =
                      bills.indexWhere((b) => b['id'] == result['id']);
                  if (index != -1) {
                    bills[index] = result;
                  }
                });
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBillScreen()),
          ).then((value) {
            if (value == true) {
              _loadBills();
            }
          });
        },
      ),
    );
  }
}
