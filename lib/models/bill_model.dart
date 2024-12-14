import 'package:bill_management/models/item_model.dart';

class BillModel {
  String id;
  String customerName;
  String contactNumber;
  List<ItemModel> items;
  double totalAmount;
  bool isPaid;
  DateTime date;

  BillModel({
    required this.id,
    required this.customerName,
    required this.contactNumber,
    required this.items,
    required this.totalAmount,
    required this.isPaid,
    required this.date,
  });
}
