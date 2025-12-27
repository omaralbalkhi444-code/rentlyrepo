import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p2/models/Item.dart';
import 'package:p2/services/firestore_service.dart';
import 'package:p2/user_manager.dart';

class EquipmentDetailLogic {
  late Item? _item;
  String ownerName = "Loading...";
  double renterWallet = 0.0;
  List<Map<String, dynamic>> topReviews = [];
  List<DateTimeRange> unavailableRanges = [];
  Map<String, dynamic>? itemInsuranceInfo;
  bool loadingAvailability = false;

  // Rental state
  String? selectedPeriod;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  int count = 1;
  String? pickupTime;
  bool insuranceAccepted = false;

  // Calculations
  double insuranceAmount = 0.0;
  double rentalPrice = 0.0;
  double totalRequired = 0.0;
  double totalPrice = 0.0;
  bool hasSufficientBalance = false;

  // Penalty info
  final double dailyPenaltyRate = 0.15;
  final double hourlyPenaltyRate = 0.05;
  final double maxPenaltyDays = 5;
  final double maxPenaltyHours = 24;
  String penaltyMessage = "";
  bool showPenaltyInfo = false;

  Item? get item => _item;
  bool get isOwner => _item != null && _item!.ownerId == UserManager.uid;

  void setItem(Item item) {
    _item = item;
  }

  Future<void> loadOwnerName(String uid) async {
    final snap = await FirebaseDatabase.instance.ref("users/$uid/name").get();
    ownerName = snap.exists ? snap.value.toString() : "Owner";
  }

  Future<void> loadItemInsuranceInfo(String itemId) async {
    try {
      final snap = await FirebaseDatabase.instance
          .ref("items/$itemId/insurance")
          .get();

      if (snap.exists) {
        final data = snap.value as Map<dynamic, dynamic>;
        itemInsuranceInfo = {
          'itemOriginalPrice': (data['itemOriginalPrice'] ?? 1000.0).toDouble(),
          'ratePercentage': (data['ratePercentage'] ?? 0.15).toDouble(),
        };
        _calculateInsuranceAmount();
      } else {
        itemInsuranceInfo = {
          'itemOriginalPrice': 1000.0,
          'ratePercentage': 0.15,
        };
        insuranceAmount = 150.0;
      }
    } catch (e) {
      itemInsuranceInfo = {
        'itemOriginalPrice': 1000.0,
        'ratePercentage': 0.15,
      };
      insuranceAmount = 150.0;
    }
  }

  Future<void> loadRenterWalletBalance() async {
    try {
      final snap = await FirebaseDatabase.instance
          .ref("users/${UserManager.uid}/wallet/balance")
          .get();

      if (snap.exists) {
        final balance = snap.value;
        renterWallet = double.tryParse(balance.toString()) ?? 0.0;
      } else {
        renterWallet = 2000.0;
      }
      _checkWalletBalance();
    } catch (e) {
      renterWallet = 0.0;
      _checkWalletBalance();
    }
  }

  Future<void> loadTopReviews(String itemId) async {
    final snap = await FirebaseDatabase.instance
        .ref("reviews/$itemId")
        .limitToFirst(3)
        .get();

    if (snap.exists) {
      topReviews = snap.children.map((c) {
        return {
          "rating": c.child("rating").value ?? 0,
          "review": c.child("review").value ?? "",
        };
      }).toList();
    } else {
      topReviews = [];
    }
  }

  Future<void> loadUnavailableRanges(String itemId) async {
    loadingAvailability = true;
    
    final rentals = await FirestoreService.getAcceptedRequestsForItem(itemId);
    unavailableRanges = rentals.map((r) {
      return DateTimeRange(
        start: DateTime.parse(r["startDate"]),
        end: DateTime.parse(r["endDate"]),
      );
    }).toList();
    
    loadingAvailability = false;
  }

  void calculateEndDate() {
    if (selectedPeriod == null) {
      endDate = null;
      return;
    }

    final p = selectedPeriod!.toLowerCase();

    if (p == "hourly") {
      if (startDate == null || startTime == null) {
        endDate = null;
        return;
      }
      final startDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      );
      endDate = startDateTime.add(Duration(hours: count));
    } else {
      if (startDate == null) {
        endDate = null;
        return;
      }
      int days = count;
      if (p == "weekly") days = count * 7;
      if (p == "monthly") days = count * 30;
      if (p == "yearly") days = count * 365;
      endDate = startDate!.add(Duration(days: days));
    }
    calculateInsurance();
  }

  double computeTotalPrice() {
    if (selectedPeriod == null || _item == null) return 0;
    final base = double.tryParse("${_item!.rentalPeriods[selectedPeriod]}") ?? 0;
    return base * count;
  }

  void calculateInsurance() {
    if (_item == null || selectedPeriod == null || itemInsuranceInfo == null) return;
    
    rentalPrice = computeTotalPrice();
    _calculateInsuranceAmount();
    totalPrice = rentalPrice + insuranceAmount;
    totalRequired = totalPrice;
    _calculatePenalties();
    _checkWalletBalance();
  }

  void _calculateInsuranceAmount() {
    if (itemInsuranceInfo == null) return;
    final itemPrice = itemInsuranceInfo!['itemOriginalPrice'];
    final rate = itemInsuranceInfo!['ratePercentage'];
    insuranceAmount = itemPrice * rate;
    insuranceAmount = (insuranceAmount / 5).ceil() * 5.0;
    if (insuranceAmount < 5) insuranceAmount = 5.0;
  }

  void _calculatePenalties() {
    if (_item == null || selectedPeriod == null || itemInsuranceInfo == null) {
      penaltyMessage = "";
      showPenaltyInfo = false;
      return;
    }

    final isHourly = selectedPeriod!.toLowerCase() == "hourly";
    final itemOriginalPrice = itemInsuranceInfo!['itemOriginalPrice'];
    
    if (isHourly) {
      final penaltyPerHour = itemOriginalPrice * hourlyPenaltyRate;
      penaltyMessage = "⏰ Hourly rental: If late more than 24 hours:\n"
          "• 5% penalty per late hour (JD ${penaltyPerHour.toStringAsFixed(2)}/hour)\n"
          "• Deducted from insurance\n";
    } else {
      final penaltyPerDay = itemOriginalPrice * dailyPenaltyRate;
      penaltyMessage = "📅 Daily/Weekly/Monthly: If late more than 5 days:\n"
          "• 15% penalty per late day (JD ${penaltyPerDay.toStringAsFixed(2)}/day)\n"
          "• Deducted from insurance\n";
    }
    
    showPenaltyInfo = true;
  }

  void _checkWalletBalance() {
    hasSufficientBalance = renterWallet >= totalRequired;
  }

  bool checkDateConflict() {
    if (startDate == null || endDate == null) return false;
    
    for (final range in unavailableRanges) {
      if ((startDate!.isBefore(range.end) || startDate!.isAtSameMomentAs(range.end)) &&
          (endDate!.isAfter(range.start) || endDate!.isAtSameMomentAs(range.start))) {
        return true;
      }
    }
    return false;
  }

  bool canRent() {
    return selectedPeriod != null &&
           startDate != null &&
           endDate != null &&
           pickupTime != null &&
           insuranceAccepted &&
           hasSufficientBalance &&
           !checkDateConflict();
  }

  String getRentButtonText() {
    if (!hasSufficientBalance) return "Insufficient Wallet Balance";
    if (!insuranceAccepted) return "Accept Insurance Terms First";
    if (pickupTime == null) return "Select Pickup Time";
    if (startDate == null || endDate == null) return "Select Dates First";
    if (selectedPeriod == null) return "Select Rental Period";
    if (checkDateConflict()) return "Dates Not Available";
    return "Confirm & Rent Now";
  }

  String formatEndDate() {
    if (endDate == null) return "";
    final isHourly = selectedPeriod?.toLowerCase() == "hourly";
    return isHourly
        ? DateFormat('yyyy-MM-dd HH:mm').format(endDate!)
        : DateFormat('yyyy-MM-dd').format(endDate!);
  }

  String getUnitLabel() {
    final p = selectedPeriod?.toLowerCase();
    if (p == "hourly") return "Hours";
    if (p == "daily") return "Days";
    if (p == "weekly") return "Weeks";
    if (p == "monthly") return "Months";
    if (p == "yearly") return "Years";
    return "";
  }
}
