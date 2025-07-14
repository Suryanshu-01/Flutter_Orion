import 'package:flutter/material.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
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
        title: const Text(
          "Parent Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF018594),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Notifications"),
                  content: const Text(
                    "Real-time transaction alerts appear here.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.shade700, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpenditureSummary(),
              const SizedBox(height: 20),
              _buildFilterDropdown(),
              const SizedBox(height: 10),
              _buildTransactionList(),
              const SizedBox(height: 20),
              _buildPaymentLockControl(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenditureSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Expenditure",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "₹ 4,200",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.42,
              backgroundColor: Colors.grey[300],
              color: Colors.cyan.shade700,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            const Text(
              "42% of monthly limit used",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Filter Transactions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyan.shade700),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              icon: Icon(Icons.arrow_drop_down, color: Colors.cyan.shade700),
              items: filters
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilter = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.map((tx) {
        return Card(
          color: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(Icons.payment, color: Colors.cyan.shade700),
            title: Text(tx["title"]),
            subtitle: Text("Date: ${tx["date"]}"),
            trailing: Text(
              "₹ ${tx["amount"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentLockControl() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      child: SwitchListTile(
        activeColor: Colors.cyan.shade700,
        title: const Text("Lock All Payments"),
        subtitle: Text(
          paymentLocked
              ? "Payments are currently locked"
              : "Payments are allowed",
        ),
        value: paymentLocked,
        onChanged: (value) {
          setState(() {
            paymentLocked = value;
          });
        },
      ),
    );
  }
}
