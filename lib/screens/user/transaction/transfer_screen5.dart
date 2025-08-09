import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransferProcessingScreen extends StatefulWidget {
  final String receiverPhone;
  final double amount;
  final String category;

  const TransferProcessingScreen({
    super.key,
    required this.receiverPhone,
    required this.amount,
    required this.category,
  });

  @override
  State<TransferProcessingScreen> createState() =>
      _TransferProcessingScreenState();
}

class _TransferProcessingScreenState extends State<TransferProcessingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isProcessing = true;
  String _statusMessage = "Processing transaction...";

  @override
  void initState() {
    super.initState();
    _performTransaction();
  }

  Future<void> _performTransaction() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not authenticated");

      final senderRef = _firestore.collection('users').doc(currentUser.uid);
      final senderSnapshot = await senderRef.get();
      final senderData = senderSnapshot.data();

      if (senderData == null || !senderData.containsKey('phone')) {
        throw Exception("Sender data is incomplete");
      }

      final senderPhone = senderData['phone'];
      final receiverQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: widget.receiverPhone)
          .limit(1)
          .get();

      if (receiverQuery.docs.isEmpty) {
        throw Exception("Receiver not found");
      }

      final receiverRef = receiverQuery.docs.first.reference;
      final receiverData = receiverQuery.docs.first.data();

      final double senderBalance = (senderData['balance'] ?? 0).toDouble();
      if (senderBalance < widget.amount) {
        setState(() {
          _isProcessing = false;
          _statusMessage = "Insufficient balance.";
        });
        return;
      }

      // Run Firestore transaction
      await _firestore.runTransaction((transaction) async {
        final newSenderBalance = senderBalance - widget.amount;
        final newReceiverBalance =
            (receiverData['balance'] ?? 0.0) + widget.amount;

        transaction.update(senderRef, {'balance': newSenderBalance});
        transaction.update(receiverRef, {'balance': newReceiverBalance});

        final txnRef = _firestore.collection('transactions').doc();
        final now = DateTime.now();

        transaction.set(txnRef, {
          'senderPhone': senderPhone,
          'receiverPhone': widget.receiverPhone,
          'amount': widget.amount,
          'timestamp': now,
          'category': widget.category,
        });
      });

      await _updateTargets(widget.amount, widget.category);

      setState(() {
        _isProcessing = false;
        _statusMessage = "Transaction Successful";
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = "Transaction failed: $e";
      });
    }
  }

  Future<void> _updateTargets(double amount, String category) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final int month = now.month;
    final int year = now.year;

    final targetsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('targets');

    final snapshot = await targetsRef
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String type = data['type']; // 'total' or 'category'
      final double targetAmount = (data['amount'] ?? 0).toDouble();
      final double spentAmount = (data['spentAmount'] ?? 0).toDouble();
      final String? targetCategory = data['category'];

      // Check if the target applies
      bool matches =
          type == 'total' || (type == 'category' && targetCategory == category);
      if (!matches) continue;

      final double updatedSpent = spentAmount + amount;
      String status =
          updatedSpent >= targetAmount ? 'ACHIEVED' : 'IN_PROGRESS';

      // Update Firestore without any notifications
      await targetsRef.doc(doc.id).update({
        'spentAmount': updatedSpent,
        'status': status,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Text(
                _statusMessage,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
