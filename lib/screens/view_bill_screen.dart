// ignore_for_file: prefer_const_constructors

import 'package:bill_management/models/bill_model.dart';
import 'package:flutter/material.dart';

class ViewBillScreen extends StatelessWidget {
  final BillModel bill;

  ViewBillScreen({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Bill')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${bill.customerName}',
                style: TextStyle(fontSize: 18)),
            Text('Contact: ${bill.contactNumber}',
                style: TextStyle(fontSize: 18)),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: bill.items.length,
                itemBuilder: (context, index) {
                  final item = bill.items[index];
                  return ListTile(
                    title: Text('${item.quantity} x ${item.itemName}'),
                    subtitle: Text(
                        'Unit Price: \$${item.unitPrice.toStringAsFixed(2)}'),
                    trailing: Text(
                        'Total: \$${(item.quantity * item.unitPrice).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Divider(),
            Text('Total: \$${bill.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18)),
            SwitchListTile(
              title: Text('Mark as Paid'),
              value: bill.isPaid,
              onChanged: (value) {
                // Update bill status in storage.
              },
            ),
          ],
        ),
      ),
    );
  }
}
