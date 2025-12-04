import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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


  Future<void> approveUser(String uid) async {
    final pendingRef = FirebaseFirestore.instance.collection("pending_users").doc(uid);
    final usersRef = FirebaseFirestore.instance.collection("users").doc(uid);

    final data = await pendingRef.get();
    if (data.exists) {
      await pendingRef.update({
        "status": "approved",
        "reviewedAt": FieldValue.serverTimestamp(),
      });

      await usersRef.set({
        "email": data["email"],
        "firstName": data["firstName"],
        "lastName": data["lastName"],
        "phone": data["phone"],
        "birthDate": data["birthDate"],
        "approvedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> rejectUser(String uid) async {
    await FirebaseFirestore.instance.collection("pending_users").doc(uid).update({
      "status": "rejected",
      "reviewedAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> submitItemForApproval({
    required String ownerId,
    required String name,
    required String description,
    required double pricePerHour,
    required double pricePerWeek,
    required double pricePerMonth,
    required double pricePerYear,
    required String category,
    required List<String> imageUrls,
  }) async {

    final docRef = FirebaseFirestore.instance.collection("pending_items").doc();

    await docRef.set({
      "itemId": docRef.id,
      "ownerId": ownerId,
      "title": name,
      "description": description,
      "pricePerHour": pricePerHour,
      "pricePerWeek": pricePerWeek,
      "pricePerMonth": pricePerMonth,
      "pricePerYear": pricePerYear,
      "category": category,
      "imageUrls": imageUrls,
      "status": "pending",
      "submittedAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> approveItem(String itemId) async {
    final pendingRef = FirebaseFirestore.instance.collection("pending_items").doc(itemId);
    final itemsRef = FirebaseFirestore.instance.collection("items").doc(itemId);

    final doc = await pendingRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;

    await itemsRef.set({
      ...data,
      "status": "approved",
      "approvedAt": FieldValue.serverTimestamp(),
    });

    await pendingRef.update({
      "status": "approved",
      "reviewedAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> rejectItem(String itemId) async {
    await FirebaseFirestore.instance.collection("pending_items")
        .doc(itemId).update({
      "status": "rejected",
      "reviewedAt": FieldValue.serverTimestamp(),
    });
  }

}
