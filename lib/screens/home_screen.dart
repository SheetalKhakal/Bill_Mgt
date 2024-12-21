// ignore_for_file: prefer_const_constructors

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
  List<Map<String, dynamic>> filteredBills = [];
  String selectedStatus = 'All';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() async {
    final db = DatabaseHelper();
    final fetchedBills = await db.getBills();
    setState(() {
      bills = List<Map<String, dynamic>>.from(fetchedBills);
      filteredBills = bills;
    });
  }

  void _filterBills() {
    setState(() {
      filteredBills = bills.where((bill) {
        final billDate = DateTime.parse(bill['date']);
        final matchesStatus = selectedStatus == 'All' ||
            (selectedStatus == 'Paid' && bill['isPaid'] == 1) ||
            (selectedStatus == 'Unpaid' && bill['isPaid'] == 0);

        final matchesDate = selectedDate == null ||
            (billDate.year == selectedDate!.year &&
                billDate.month == selectedDate!.month &&
                billDate.day == selectedDate!.day);

        return matchesStatus && matchesDate;
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      _filterBills();
    }
  }

  void _removeBillFromList(int billId) {
    setState(() {
      bills.removeWhere((bill) => bill['id'] == billId);
      filteredBills.removeWhere((bill) => bill['id'] == billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Management'),
        backgroundColor: Colors.blue[50],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedStatus = value;
              });
              _filterBills();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Paid', child: Text('Paid')),
              PopupMenuItem(value: 'Unpaid', child: Text('Unpaid')),
            ],
            child: Icon(
              Icons.filter_list,
              color: Colors.cyanAccent[700],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.deepPurple,
            ),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredBills.length,
        itemBuilder: (context, index) {
          final bill = filteredBills[index];
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
                  _filterBills();
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
