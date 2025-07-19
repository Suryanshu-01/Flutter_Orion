import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  
  Future<double> fetchTotalYearlyExpense({int? year}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      year ??= DateTime.now().year;

      final querySnapshot = await FirebaseFirestore.instance
          .collection("transactions")
          .where("participants", arrayContains: uid)
          .where("status", isEqualTo: "success")
          .where("type", isEqualTo: "transfer")
          .get();

      double total = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dateString = data["date"];
        final amount = (data["amount"] ?? 0).toDouble();

        final date = DateTime.tryParse(dateString ?? "");
        if (date != null && date.year == year && data["from"] == uid) {
          total += amount;
        }
      }

      return total;
    } catch (e) {
      print("Error fetching total expense: $e");
      return 0.0;
    }
  }
}
