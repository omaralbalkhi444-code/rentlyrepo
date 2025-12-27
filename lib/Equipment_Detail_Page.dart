import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:p2/logic/equipment_detail_logic.dart';
import 'package:p2/models/Item.dart';
import 'package:p2/services/firestore_service.dart';
import 'package:p2/user_manager.dart';
import 'FavouriteManager.dart';
import 'ChatScreen.dart';
import 'AllReviewsPage.dart';

class EquipmentDetailPage extends StatefulWidget {
  static const routeName = '/product-details';
  const EquipmentDetailPage({super.key});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  late EquipmentDetailLogic _logic;
  int currentPage = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _logic = EquipmentDetailLogic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Item) {
        _logic.setItem(args);
        _loadAllData(args);
      }
      _loaded = true;
    }
  }

  Future<void> _loadAllData(Item item) async {
    await _logic.loadOwnerName(item.ownerId);
    await _logic.loadTopReviews(item.id);
    await _logic.loadUnavailableRanges(item.id);
    await _logic.loadItemInsuranceInfo(item.id);
    await _logic.loadRenterWalletBalance();
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_logic.item == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final item = _logic.item!;
    final periods = item.rentalPeriods.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopHeader(context),
              _buildImageSlider(item.images),
              _buildHeader(item),
              _buildOwnerSection(),
              _buildDescription(item),
              _buildRatingSection(item),

              if (!_logic.isOwner) ...[
                _buildRentalChips(periods, item),
                _buildRentalSelector(item),
                _buildAvailabilityHint(),
                _buildEndDateDisplay(),
                _buildTotalPrice(item),
                _buildInsuranceAndBalanceSection(),
                _buildPenaltyInfoSection(),
                _buildInsuranceTermsCheckbox(),
                _buildPickupSelector(),
                _buildRentButton(item),
              ] else ...[
                _buildOwnerMessage(),
              ],

              _buildReviewsSection(item),
              _buildMapSection(item),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Item Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    return Container(
      height: 260,
      margin: const EdgeInsets.all(12),
      child: PageView.builder(
        onPageChanged: (i) => setState(() => currentPage = i),
        itemCount: images.isEmpty ? 1 : images.length,
        itemBuilder: (_, i) {
          if (images.isEmpty) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 90),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(images[i], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Item item) {
    final isFav = FavouriteManager.isFavourite(item.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFav ? Colors.red : Colors.grey,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                isFav
                    ? FavouriteManager.remove(item.id)
                    : FavouriteManager.add(item.id);
              });
            },
          ),
          if (!_logic.isOwner)
            IconButton(
              icon: const Icon(Icons.chat, color: Color(0xFF8A005D), size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      personUid: item.ownerId,
                      personName: _logic.ownerName,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.person, color: Color(0xFF8A005D)),
          const SizedBox(width: 8),
          Text("Owner: ${_logic.ownerName}"),
        ],
      ),
    );
  }

  Widget _buildOwnerMessage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "This is your item. You cannot rent your own item.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(Item item) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(item.description,
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
    );
  }

  Widget _buildRatingSection(Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber[700], size: 22),
          const SizedBox(width: 4),
          Text("${item.averageRating.toStringAsFixed(1)} (${item.ratingCount})"),
        ],
      ),
    );
  }

  Widget _buildRentalChips(List<String> periods, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: periods.map((p) {
          return ChoiceChip(
            label: Text("$p (JD ${item.rentalPeriods[p]})"),
            selected: _logic.selectedPeriod == p,
            onSelected: (_) {
              setState(() {
                _logic.selectedPeriod = p;
                _logic.startDate = null;
                _logic.endDate = null;
                _logic.startTime = null;
                _logic.count = 1;
                _logic.pickupTime = null;
                _logic.insuranceAccepted = false;
                _logic.calculateInsurance();
              });
            },
            selectedColor: const Color(0xFF8A005D),
            labelStyle: TextStyle(
              color: _logic.selectedPeriod == p ? Colors.white : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRentalSelector(Item item) {
    if (_logic.selectedPeriod == null) return const SizedBox.shrink();
    final p = _logic.selectedPeriod!.toLowerCase();

    if (p == "hourly") return _buildHourlySelector();
    return _buildDaySelector();
  }

  Widget _buildHourlySelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker("Start Date", _logic.startDate, (d) {
            setState(() {
              _logic.startDate = d;
              _logic.calculateEndDate();
            });
          }),
          const SizedBox(height: 16),
          _buildTimePicker("Start Time", _logic.startTime, (t) {
            setState(() {
              _logic.startTime = t;
              _logic.calculateEndDate();
            });
          }),
          const SizedBox(height: 22),
          const Text(
            "Number of Hours",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_logic.count > 1) {
                      setState(() {
                        _logic.count--;
                        _logic.calculateEndDate();
                      });
                    }
                  },
                  child: const Icon(Icons.remove,
                      color: Color(0xFF8A005D), size: 26),
                ),
                Text(
                  "${_logic.count} Hours",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A005D),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _logic.count++;
                      _logic.calculateEndDate();
                    });
                  },
                  child: const Icon(Icons.add,
                      color: Color(0xFF8A005D), size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker("Start Date", _logic.startDate, (d) {
            setState(() {
              _logic.startDate = d;
              _logic.calculateEndDate();
            });
          }),
          const SizedBox(height: 22),
          Text(
            "Number of ${_logic.getUnitLabel()}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_logic.count > 1) {
                      setState(() {
                        _logic.count--;
                        _logic.calculateEndDate();
                      });
                    }
                  },
                  child: const Icon(Icons.remove,
                      color: Color(0xFF8A005D), size: 26),
                ),
                Text(
                  "${_logic.count} ${_logic.getUnitLabel()}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A005D),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _logic.count++;
                      _logic.calculateEndDate();
                    });
                  },
                  child: const Icon(Icons.add, color: Color(0xFF8A005D), size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceAndBalanceSection() {
    if (_logic.selectedPeriod == null || _logic.startDate == null || _logic.endDate == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F0F46),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Insurance & Wallet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Insurance Required",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          "Item Original Price:",
                          "JD ${(_logic.itemInsuranceInfo?['itemOriginalPrice'] ?? 0).toStringAsFixed(2)}",
                        ),
                        _buildDetailRow(
                          "Insurance Rate:",
                          "${((_logic.itemInsuranceInfo?['ratePercentage'] ?? 0) * 100).toInt()}%",
                        ),
                        const Divider(),
                        _buildDetailRow(
                          "Insurance Amount:",
                          "JD ${_logic.insuranceAmount.toStringAsFixed(2)}",
                          isBold: true,
                          color: Colors.blue[900],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: _logic.hasSufficientBalance ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _logic.hasSufficientBalance ? Icons.account_balance_wallet : Icons.warning,
                        color: _logic.hasSufficientBalance ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _logic.hasSufficientBalance ? "Sufficient Balance" : "Check Your Balance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _logic.hasSufficientBalance ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildBalanceRow(
                          "Rental Price:",
                          _logic.rentalPrice,
                        ),
                        _buildBalanceRow(
                          "Insurance Amount:",
                          _logic.insuranceAmount,
                        ),
                        const Divider(),
                        _buildBalanceRow(
                          "Total Price:", 
                          _logic.totalPrice, 
                          isTotal: true,
                          color: _logic.hasSufficientBalance ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Wallet Balance:",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "JD ${_logic.renterWallet.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _logic.renterWallet > 0 ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (!_logic.hasSufficientBalance) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.orange[800], size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Insufficient Balance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "You need JD ${(_logic.totalRequired - _logic.renterWallet).toStringAsFixed(2)} more",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyInfoSection() {
    if (!_logic.showPenaltyInfo || _logic.penaltyMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange.shade300, width: 1),
        ),
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, 
                  color: Colors.orange[800], size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _logic.penaltyMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              color: isTotal ? Colors.black : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "JD ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? Color(0xFF8A005D) : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityHint() {
    if (_logic.loadingAvailability) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    if (_logic.unavailableRanges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text(
              "Fully available for selected dates",
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚠️ Unavailable Periods",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          ..._logic.unavailableRanges.map((r) => Text(
            "• ${DateFormat('MMM d, HH:mm').format(r.start)} → ${DateFormat('MMM d, HH:mm').format(r.end)}",
            style: const TextStyle(color: Colors.red, fontSize: 13),
          )),
          const SizedBox(height: 8),
          const Text(
            "Please select different dates to proceed.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      String title, DateTime? value, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final pick = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (pick != null) onSelect(pick);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A005D),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              value == null
                  ? "Select Start Date"
                  : DateFormat("yyyy-MM-dd").format(value),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(
      String title, TimeOfDay? value, Function(TimeOfDay) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final pick =
                  await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (pick != null) onSelect(pick);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A005D),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(value == null ? "Select Time" : value.format(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateDisplay() {
    if (_logic.endDate == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        _logic.formatEndDate(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A005D),
        ),
      ),
    );
  }

  Widget _buildTotalPrice(Item item) {
    if (_logic.selectedPeriod == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rental Price:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "JD ${_logic.rentalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A005D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsuranceTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _logic.insuranceAccepted,
                onChanged: (value) {
                  setState(() {
                    _logic.insuranceAccepted = value ?? false;
                  });
                },
                activeColor: const Color(0xFF8A005D),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Accept Owner's Insurance Terms",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "By checking this box, I agree to:\n"
                      "• Accept the insurance coverage required by owner\n"
                      "• Pay insurance amount of JD ${_logic.insuranceAmount.toStringAsFixed(2)}\n"
                      "• Report any damages immediately\n"
                      "• Understand insurance will be refunded if item returned safely",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              "Pickup Time",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final pick = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (pick != null) {
                  setState(() => _logic.pickupTime = pick.format(context));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A005D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _logic.pickupTime == null ? "Select Pickup Time" : _logic.pickupTime!,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentButton(Item item) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                const Text(
                  "Final Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F0F46),
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildSummaryRow("Rental Price:", _logic.rentalPrice),
                _buildSummaryRow("Insurance:", _logic.insuranceAmount),
                
                const Divider(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price:", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "JD ${_logic.totalPrice.toStringAsFixed(2)}", 
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8A005D),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Wallet Balance:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "JD ${_logic.renterWallet.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _logic.hasSufficientBalance ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                
                if (!_logic.hasSufficientBalance)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[800], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You need JD ${(_logic.totalPrice - _logic.renterWallet).toStringAsFixed(2)} more",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _logic.canRent() ? const Color(0xFF8A005D) : Colors.grey,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _logic.canRent() ? 3 : 0,
            ),
            onPressed: _logic.canRent() ? () => _submitRentalRequest(item) : null,
            child: Text(
              _logic.getRentButtonText(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          if (!_logic.hasSufficientBalance) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8A005D)),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/wallet');
              },
              child: const Text(
                "Go to Wallet",
                style: TextStyle(color: Color(0xFF8A005D)),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double amount, {String? note}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text("JD ${amount.toStringAsFixed(2)}"),
              if (note != null)
                Text(
                  " $note",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitRentalRequest(Item item) async {
    final isHourly = _logic.selectedPeriod!.toLowerCase() == "hourly";
    
    final data = {
      "itemId": item.id,
      "itemTitle": item.name,
      "itemOwnerUid": item.ownerId,
      "customerUid": UserManager.uid,
      "customerName": UserManager.name,
      "status": "pending",
      "rentalType": _logic.selectedPeriod,
      "rentalQuantity": _logic.count,
      "startDate": _logic.startDate!.toIso8601String(),
      "endDate": _logic.endDate!.toIso8601String(),
      "startTime": isHourly ? _logic.startTime!.format(context) : null,
      "endTime": isHourly
          ? TimeOfDay.fromDateTime(_logic.endDate!)
              .format(context)
          : null,
      "pickupTime": _logic.pickupTime,
      "rentalPrice": _logic.rentalPrice,
      "insuranceInfo": _logic.itemInsuranceInfo,
      "insuranceAmount": _logic.insuranceAmount,
      "totalPrice": _logic.totalPrice,
      "totalRequired": _logic.totalRequired,
      "createdAt": DateTime.now().toIso8601String(),
      "insuranceAccepted": _logic.insuranceAccepted,
      "renterWalletBefore": _logic.renterWallet,
      "penaltyInfo": {
        "dailyPenaltyRate": _logic.dailyPenaltyRate,
        "hourlyPenaltyRate": _logic.hourlyPenaltyRate,
        "maxPenaltyDays": _logic.maxPenaltyDays,
        "maxPenaltyHours": _logic.maxPenaltyHours,
        "penaltyMessage": _logic.penaltyMessage,
      },
    };
    
    final confirmed = await _showConfirmationDialog(data, item);
    if (!confirmed) return;
    
    try {
      await FirestoreService.createRentalRequest(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Rental request submitted successfully!"),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      Navigator.pushNamedAndRemoveUntil(
        context, 
        "/orders", 
        (route) => false
      );
      
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Failed to submit rental request"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unexpected error. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog(Map<String, dynamic> data, Item item) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Rental Request"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please review your order details:"),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text("Owner: ${_logic.ownerName}"),
                    Text("Period: ${_logic.selectedPeriod!.toUpperCase()}"),
                    Text("Duration: ${_logic.count} ${_logic.selectedPeriod!.toLowerCase() == 'hourly' ? 'hours' : _logic.selectedPeriod!.toLowerCase()}"),
                    Text("Dates: ${DateFormat('MMM d, yyyy').format(_logic.startDate!)} - ${DateFormat('MMM d, yyyy').format(_logic.endDate!)}"),
                    if (_logic.pickupTime != null) Text("Pickup: ${_logic.pickupTime}"),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Insurance Details:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text("Item Price: JD ${_logic.itemInsuranceInfo!['itemOriginalPrice']!.toStringAsFixed(2)}"),
                    Text("Insurance Rate: ${(_logic.itemInsuranceInfo!['ratePercentage']! * 100).toInt()}%"),
                    Text("Insurance: JD ${_logic.insuranceAmount.toStringAsFixed(2)}"),
                    const Text("Insurance will be refunded when item returned safely"),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[800], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Late Return Penalty:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      _logic.penaltyMessage,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price Summary:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    _buildDialogRow("Rental Payment to Owner:", _logic.rentalPrice),
                    _buildDialogRow("Insurance Payment to System:", _logic.insuranceAmount),
                    const Divider(),
                    _buildDialogRow("Total Price:", _logic.totalPrice, isBold: true),
                    const SizedBox(height: 4),
                    Text(
                      "Current Wallet Balance: JD ${_logic.renterWallet.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                "By confirming, you agree to:\n"
                "• Rental terms and conditions\n"
                "• Insurance coverage selected by owner\n"
                "• Late return penalty policy\n"
                "• Report any damages immediately\n"
                "• Return and refund policy",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A005D),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm & Proceed"),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Widget _buildDialogRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          Text(
            "JD ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isBold ? const Color(0xFF8A005D) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reviews",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_logic.topReviews.isEmpty)
            const Text(
              "No reviews yet",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _logic.topReviews.map((rev) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 350),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 6),
                          Text("${rev['rating']}"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rev['review'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllReviewsPage(itemId: item.id),
                  ),
                );
              },
              child: const Text("Show All Reviews →"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(Item item) {
    if (item.latitude == null || item.longitude == null) {
      return Container(
        height: 150,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "📍 Location not provided",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(item.latitude!, item.longitude!),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("itemLoc"),
            position: LatLng(item.latitude!, item.longitude!),
          )
        },
      ),
    );
  }
}
