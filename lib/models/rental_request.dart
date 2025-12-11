import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemOwnerUid;

  final String customerUid; // renter ID

  final String rentalType;
  final int rentalQuantity;

  final DateTime startDate;
  final DateTime endDate;

  final String? startTime; // only for hourly
  final String? endTime;   // only for hourly
  final String? pickupTime;

  final num totalPrice;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  RentalRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemOwnerUid,
    required this.customerUid,
    required this.rentalType,
    required this.rentalQuantity,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.pickupTime,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RentalRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return RentalRequest(
      id: id,
      itemId: data["itemId"] ?? "",
      itemTitle: data["itemTitle"] ?? "",
      itemOwnerUid: data["itemOwnerUid"] ?? "",
      customerUid: data["customerUid"] ?? "",
      rentalType: data["rentalType"] ?? "",
      rentalQuantity: data["rentalQuantity"] ?? 0,

      startDate: DateTime.parse(data["startDate"]),
      endDate: DateTime.parse(data["endDate"]),

      startTime: data["startTime"],
      endTime: data["endTime"],
      pickupTime: data["pickupTime"],

      totalPrice: data["totalPrice"] ?? 0,
      status: data["status"] ?? "pending",

      // createdAt is Timestamp → convert safely
      createdAt: data["createdAt"] != null
          ? (data["createdAt"] as Timestamp).toDate()
          : null,

      updatedAt: data["updatedAt"] != null
          ? (data["updatedAt"] as Timestamp).toDate()
          : null,
    );
  }
}
