import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_success6.dart';

class TransferProcessingScreen extends StatefulWidget {
  final String receiverPhone;
  final double amount;
  final String paymentType;

  const TransferProcessingScreen({
    super.key,
    required this.receiverPhone,
    required this.amount,
    required this.paymentType,
  });

  @override
  State<TransferProcessingScreen> createState() => _TransferProcessingScreenState();
}

class _TransferProcessingScreenState extends State<TransferProcessingScreen> {
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
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final sender = auth.currentUser;

    try {
      final senderRef = firestore.collection('users').doc(sender!.uid);

      return await firestore.runTransaction((transaction) async {
        final senderSnap = await transaction.get(senderRef);
        if (!senderSnap.exists) throw Exception("Sender not found");

        final dynamic senderRaw = senderSnap['walletBalance'];
        double senderBalance;
        if (senderRaw is int) {
          senderBalance = senderRaw.toDouble();
        } else if (senderRaw is double) {
          senderBalance = senderRaw;
        } else if (senderRaw is String) {
          senderBalance = double.tryParse(senderRaw) ?? 0.0;
        } else {
          throw Exception("Invalid sender balance format");
        }

        if (senderBalance < amount) throw Exception("Insufficient balance");

        final receiverQuery = await firestore
            .collection('users')
            .where('phone', isEqualTo: widget.receiverPhone)
            .get();

        if (receiverQuery.docs.isEmpty) {
          throw Exception("Receiver not found");
        }

        final receiverDoc = receiverQuery.docs.first;
        final receiverRef = receiverDoc.reference;

        final dynamic receiverRaw = receiverDoc['walletBalance'];
        double receiverBalance;
        if (receiverRaw is int) {
          receiverBalance = receiverRaw.toDouble();
        } else if (receiverRaw is double) {
          receiverBalance = receiverRaw;
        } else if (receiverRaw is String) {
          receiverBalance = double.tryParse(receiverRaw) ?? 0.0;
        } else {
          throw Exception("Invalid receiver balance format");
        }

        // Update balances
        transaction.update(senderRef, {'walletBalance': senderBalance - amount});
        transaction.update(receiverRef, {'walletBalance': receiverBalance + amount});

        // Prepare transaction details
        final now = DateTime.now();
        final today = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('HH:mm:ss').format(now);
        final transactionId = firestore.collection('transactions').doc().id;

        final transactionData = {
          'transactionId': transactionId,
          'from': sender.uid,
          'to': receiverDoc.id,
          'participants': [sender.uid, receiverDoc.id], // ✅ Key for easy querying
          'amount': amount,
          'date': today,
          'time': time,
          'type': 'transfer',
          'status': 'success',
          'category': widget.paymentType,
        };

        // Save single transaction record
        transaction.set(
          firestore.collection('transactions').doc(transactionId),
          transactionData,
        );

        return true;
      });
    } catch (e) {
      _showSnackBar("Transfer failed: $e");
      return false;
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
