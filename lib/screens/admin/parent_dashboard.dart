import 'package:flutter/material.dart';

class ParentDashboard extends StatefulWidget {
  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  bool paymentLocked = false;
  String selectedFilter = "All";

  List<String> filters = [
    "All",
    "Highest Spending Day",
    "Most Paid Person",
    "Suspicious Transactions",
  ];

  List<Map<String, dynamic>> transactions = [
    {"title": "Grocery", "amount": 500, "date": "2025-07-04"},
    {"title": "Mobile Recharge", "amount": 200, "date": "2025-07-03"},
    {"title": "Snacks", "amount": 150, "date": "2025-07-03"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Notifications"),
                  content: Text("Real-time transaction alerts appear here."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpenditureSummary(),
            SizedBox(height: 20),
            _buildFilterDropdown(),
            SizedBox(height: 10),
            _buildTransactionList(),
            SizedBox(height: 20),
            _buildPaymentLockControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenditureSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Expenditure",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("₹ 4,200"),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.42, // 42% of budget used
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text("42% of monthly limit used")
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Filter Transactions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedFilter,
          items: filters
              .map((filter) =>
                  DropdownMenuItem(value: filter, child: Text(filter)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedFilter = value;
                // You can add filtering logic here
              });
            }
          },
        )
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.map((tx) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(Icons.payment),
            title: Text(tx["title"]),
            subtitle: Text("Date: ${tx["date"]}"),
            trailing: Text(
              "₹ ${tx["amount"]}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentLockControl() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text("Lock All Payments"),
        subtitle: Text(paymentLocked
            ? "Payments are currently locked"
            : "Payments are allowed"),
        value: paymentLocked,
        onChanged: (value) {
          setState(() {
            paymentLocked = value;
            // You can trigger backend API call here
          });
        },
      ),
    );
  }
}
