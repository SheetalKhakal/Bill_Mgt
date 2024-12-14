// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:bill_management/database_helper.dart';
import 'package:bill_management/models/bill_model.dart';
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
      bills = fetchedBills;
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
            subtitle: Text('Total: ${bill['totalAmount']} - ${bill['date']}'),
            trailing: Text(bill['isPaid'] == 1 ? 'Paid' : 'Unpaid'),
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
