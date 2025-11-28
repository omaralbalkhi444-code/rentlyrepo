

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'Orders.dart';
import 'EquipmentItem.dart';
import 'Favourite.dart';

class EquipmentDetailPage extends StatefulWidget {
  static const routeName = '/product-details';
  const EquipmentDetailPage({super.key});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  bool isFavoritePressed = false;
  int _currentPage = 0;
  
  RentalType selectedRentalType = RentalType.hourly;

  DateTime? startDate;
  DateTime? endDate;
  String? pickupTime;

  bool isLiked = false;
  int likesCount = 0;

  double userRating = 0.0;
  final TextEditingController reviewController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  double calculateTotalPrice(EquipmentItem equipment) {
    final basePrice = equipment.getPriceForRentalType(selectedRentalType);
    
    if (startDate != null && endDate != null) {
      final difference = endDate!.difference(startDate!).inDays;
      switch (selectedRentalType) {
        case RentalType.hourly:
          return basePrice * 24 * difference;
        case RentalType.weekly:
          return basePrice * (difference / 7);
        case RentalType.monthly:
          return basePrice * (difference / 30);
        case RentalType.yearly:
          return basePrice * (difference / 365);
      }
    }
    
    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final equipment =
        ModalRoute.of(context)?.settings.arguments as EquipmentItem?;

    if (equipment == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No product data provided!",
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      );
    }

    isFavoritePressed = FavouriteManager.favouriteItems.contains(equipment);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 280,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    PageView.builder(
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Icon(
                            equipment.icon,
                            size: 140,
                            color: const Color(0xFF8A005D),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.black87, size: 26),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFavoritePressed) {
                              isFavoritePressed = false;
                              FavouriteManager.remove(equipment);
                            } else {
                              isFavoritePressed = true;
                              FavouriteManager.add(equipment);
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavoritePressed
                                    ? '${equipment.title} added to Favorites'
                                    : '${equipment.title} removed from Favorites',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.favorite,
                          color: isFavoritePressed ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? const Color(0xFF8A005D)
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.title,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                double tempRating = userRating;
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(20),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: StatefulBuilder(
                                      builder: (context, setStateSB) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Rate this product",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(5, (index) {
                                                return IconButton(
                                                  onPressed: () {
                                                    setStateSB(() {
                                                      tempRating = (index + 1).toDouble();
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.star,
                                                    color: (index + 1) <= tempRating
                                                        ? Colors.amber
                                                        : Colors.grey,
                                                    size: 40,
                                                  ),
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 20),
                                            Container(
                                              height: 4,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Colors.amber, Colors.grey],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    child: const Text(
                                                      "Cancel",
                                                      style: TextStyle(fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        userRating = tempRating;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF8A005D),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    child: const Text(
                                                      "OK",
                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber[700], size: 22),
                              const SizedBox(width: 4),
                              Text("$userRating",
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLiked = !isLiked;
                              likesCount = isLiked ? 1 : 0;
                            });
                          },
                          child: Icon(
                            Icons.thumb_up,
                            color: isLiked ? Colors.green : Colors.grey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text("$likesCount",
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Rental Period:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildRentalTypeChip("Hourly", RentalType.hourly, equipment),
                              const SizedBox(width: 8),
                              _buildRentalTypeChip("Weekly", RentalType.weekly, equipment),
                              const SizedBox(width: 8),
                              _buildRentalTypeChip("Monthly", RentalType.monthly, equipment),
                              const SizedBox(width: 8),
                              _buildRentalTypeChip("Yearly", RentalType.yearly, equipment),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Total: JOD ${calculateTotalPrice(equipment).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A005D),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 14),
                    Text(equipment.description,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 14),
                    Text("Release Year: ${equipment.releaseYear}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 14),
                    const Text("Specifications:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ...equipment.specs.map(
                      (spec) =>
                          Text("• $spec", style: const TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(startDate == null
                              ? "Start Date"
                              : DateFormat('yyyy-MM-dd').format(startDate!)),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(endDate == null
                              ? "End Date"
                              : DateFormat('yyyy-MM-dd').format(endDate!)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            pickupTime = picked.format(context);
                          });
                        }
                      },
                      child: Text(pickupTime == null
                          ? "Select Pickup Time"
                          : pickupTime!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        TextEditingController c = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("Write a Review"),
                              content: TextField(
                                controller: c,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: "Write your comment...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (c.text.isNotEmpty) {
                                      setState(() {
                                        equipment.userReviews =
                                            List<String>.from(
                                          equipment.userReviews,
                                        );
                                        equipment.userReviews.add(c.text);
                                        equipment.reviews++;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Submit"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("Write Review"),
                    ),
                    const SizedBox(height: 10),
                    if (equipment.userReviews.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("All Reviews"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: equipment.userReviews
                                        .map((rev) => ListTile(
                                              title: Text(rev),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("See All"),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        OrdersManager.addOrder(equipment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${equipment.title} added to Orders'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        Future.delayed(
                            const Duration(milliseconds: 300), () {
                          Navigator.pushNamed(context, '/orders');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A005D),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Rent Now",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            equipment.latitude ?? 32.55,
                            equipment.longitude ?? 35.85,
                          ),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("itemLocation"),
                            position: LatLng(
                              equipment.latitude ?? 32.55,
                              equipment.longitude ?? 35.85,
                            ),
                            infoWindow: const InfoWindow(
                                title: "Equipment Location"),
                            icon:
                                BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                        myLocationEnabled: false,
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentalTypeChip(String label, RentalType type, EquipmentItem equipment) {
    bool isSelected = selectedRentalType == type;
    return ChoiceChip(
      label: Text("$label (JOD ${equipment.getPriceForRentalType(type).toStringAsFixed(2)})"),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedRentalType = type;
        });
      },
      selectedColor: const Color(0xFF8A005D),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  // ignore: unused_element
  String _getRentalTypeText(RentalType type) {
    switch (type) {
      case RentalType.hourly:
        return 'hour';
      case RentalType.weekly:
        return 'week';
      case RentalType.monthly:
        return 'month';
      case RentalType.yearly:
        return 'year';
    }
  }
}



