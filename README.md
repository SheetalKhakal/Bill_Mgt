Bill Management System

Overview

The Bill Management System is a Flutter-based mobile application designed to create and manage invoices efficiently. This app allows users to add customer details, manage product items, calculate total amounts, and save invoices into a local database.

Features

•	Generate Invoice: Automatically generate unique invoice numbers and date stamps.

•	Customer Details: Add customer name and contact number with validation.

•	Product Management: Add, edit, and delete product items with quantity, unit price, and total price calculation.

•	Invoice Summary: Display the total amount of all products.

•	Save Bills: Persist invoices and related product details using a local SQLite database.

Screens

1. Generate Invoice Screen

•	Input customer name and validated contact number.

•	Add multiple product items.

•	View invoice summary and total amount.

•	Save the invoice to the database.

Technologies Used

•	Flutter: For building the user interface.

•	SQLite: For local data storage.

•	Intl Package: For date formatting.

Installation

1.	Clone the repository:

git clone  https://github.com/SheetalKhakal/Bill_Mgt.git

2.	Navigate to the project directory:

cd bill-management

3.	Install dependencies:

flutter pub get

4.	Run the application:

flutter run
 
Database Schema

Tables

•	Bills Table

o	id: Primary key

o	customerName: Name of the customer

o	contactNumber: Customer's contact number

o	totalAmount: Total bill amount

o	isPaid: Payment status

o	date: Timestamp of the invoice

•	Items Table

o	id: Primary key

o	billId: Foreign key linking to Bills table

o	itemName: Name of the item

o	quantity: Quantity of the item

o	unitPrice: Unit price of the item
 
 

