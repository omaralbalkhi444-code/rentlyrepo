import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  static final functions =
  FirebaseFunctions.instanceFor(region: "us-central1");

  static Future<void> submitUserForApproval(Map<String, dynamic> data) async {
    final callable = FirebaseFunctions.instance
        .httpsCallableFromUrl(
        "https://us-central1-p22rently.cloudfunctions.net/submitUserForApproval"
    );

    await callable.call(data);
  }

  static Future<void> submitItemForApproval(Map<String, dynamic> data) async {
    await FirebaseFunctions.instance
        .httpsCallable("submitItemForApproval")
        .call(data);
  }

  static Future<void> createRentalRequest({
    required String itemId,
    required String itemTitle,
    required String itemOwnerUid,
    required String rentalType,
    required String startDate,
    required String endDate,
    String? startTime,
    String? endTime,
    required String pickupTime,
    required double totalPrice,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception("User not logged in.");
    }

    await FirebaseFirestore.instance.collection("rentalRequests").add({
      "itemId": itemId,
      "itemTitle": itemTitle,
      "itemOwnerUid": itemOwnerUid,
      "customerUid": uid,

      "rentalType": rentalType,
      "startDate": startDate,
      "endDate": endDate,
      "startTime": startTime,
      "endTime": endTime,
      "pickupTime": pickupTime,
      "totalPrice": totalPrice.toStringAsFixed(2),

      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
