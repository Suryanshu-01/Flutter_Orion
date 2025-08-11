import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_success6.dart';

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
  State<TransferProcessingScreen> createState() => _TransferProcessingScreenState();
}

class _TransferProcessingScreenState extends State<TransferProcessingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startTransfer();
  }

  Future<void> _startTransfer() async {
    bool result = await _performTransfer(widget.amount);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(isSuccess: result),
      ),
    );
  }

  Future<bool> _performTransfer(double amount) async {
    final sender = _auth.currentUser;
    if (sender == null) {
      _showSnackBar("User not authenticated");
      return false;
    }

    try {
      final senderRef = _firestore.collection('users').doc(sender.uid);

      return await _firestore.runTransaction((transaction) async {
        final senderSnap = await transaction.get(senderRef);
        if (!senderSnap.exists) throw Exception("Sender not found");

        final dynamic senderRaw = senderSnap['walletBalance'];
        double senderBalance = _parseBalance(senderRaw);

        if (senderBalance < amount) throw Exception("Insufficient balance");

        final receiverQuery = await _firestore
            .collection('users')
            .where('phone', isEqualTo: widget.receiverPhone)
            .limit(1)
            .get();

        if (receiverQuery.docs.isEmpty) throw Exception("Receiver not found");

        final receiverDoc = receiverQuery.docs.first;
        final receiverRef = receiverDoc.reference;
        final dynamic receiverRaw = receiverDoc['walletBalance'];
        double receiverBalance = _parseBalance(receiverRaw);

        transaction.update(senderRef, {'walletBalance': senderBalance - amount});
        transaction.update(receiverRef, {'walletBalance': receiverBalance + amount});

        final now = DateTime.now();
        final transactionId = _firestore.collection('transactions').doc().id;

        final transactionData = {
          'transactionId': transactionId,
          'from': sender.uid,
          'to': receiverDoc.id,
          'participants': [sender.uid, receiverDoc.id],
          'amount': amount,
          'date': DateFormat('yyyy-MM-dd').format(now),
          'time': DateFormat('HH:mm:ss').format(now),
          'timestamp': Timestamp.fromDate(now),
          'type': 'transfer',
          'status': 'success',
          'category': widget.category,
        };

        transaction.set(
          _firestore.collection('transactions').doc(transactionId),
          transactionData,
        );


        return true;
      }).then((success) async {
        if (success) {
          await _updateTargets(amount, widget.category);
        }
        return success;
      });
    } catch (e) {
      _showSnackBar("Transfer failed: $e");
      return false;
    }
  }

  double _parseBalance(dynamic raw) {
    if (raw is int) return raw.toDouble();
    if (raw is double) return raw;
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
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
      final String type = data['type'];
      final double targetAmount = (data['amount'] ?? 0).toDouble();
      final double spentAmount = (data['spentAmount'] ?? 0).toDouble();
      final String? targetCategory = data['category'];

      bool matches = type == 'total' || (type == 'category' && targetCategory == category);
      if (!matches) continue;

      final double updatedSpent = spentAmount + amount;
      String status = updatedSpent >= targetAmount ? 'ACHIEVED' : 'IN_PROGRESS';

      await targetsRef.doc(doc.id).update({
        'spentAmount': updatedSpent,
        'status': status,
      });
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
