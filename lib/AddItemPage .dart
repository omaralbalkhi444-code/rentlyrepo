import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'EquipmentItem.dart';
import 'package:p2/services/storage_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, this.item});

  final EquipmentItem? item;

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCategory;
  String? selectedSubCategory;

  final Map<String, String> selectedRentalPeriods = {};
  String? newRentalPeriod;

  List<File> pickedImages = [];

  final List<String> categories = [
    "Electronics",
    "Computers & Mobiles",
    "Video Games",
    "Sports",
    "Tools & Devices",
    "Home & Garden",
    "Fashion & Clothing",
  ];

  final Map<String, List<String>> subCategories = {
    "Electronics": ["Cameras & Photography", "Audio & Video"],
    "Computers & Mobiles": [
      "Mobiles",
      "Laptops",
      "Printers",
      "Projectors",
      "Servers",
    ],
    "Video Games": ["Gaming Devices"],
    "Sports": [
      "Bicycle",
      "Books",
      "Skates & Scooters",
      "Camping",
    ],
    "Tools & Devices": [
      "Maintenance Tools",
      "Medical Devices",
      "Cleaning Equipment"
    ],
    "Home & Garden": [
      "Garden Equipment",
      "Home Supplies",
    ],
    "Fashion & Clothing": [
      "Men",
      "Women",
      "Customs",
      "Baby Supplies",
    ],
  };

  final List<String> availableRentalPeriods = [
    'Hourly',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  Future<void> pickImages() async {
    final List<XFile>? files = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (files != null) {
      setState(() {
        int remaining = 5 - pickedImages.length;
        if (remaining > 0) {
          pickedImages.addAll(
            files.take(remaining).map((f) => File(f.path)).toList(),
          );
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() => pickedImages.removeAt(index));
  }

  void removeRentalPeriod(String period) {
    setState(() => selectedRentalPeriods.remove(period));
  }

  void addNewRentalPeriod() {
    if (newRentalPeriod == null || priceController.text.isEmpty) {
      showError("Please select a period and enter price");
      return;
    }

    final price = double.tryParse(priceController.text);
    if (price == null || price <= 0) {
      showError("Invalid price");
      return;
    }

    if (selectedRentalPeriods.containsKey(newRentalPeriod)) {
      showError("$newRentalPeriod already added");
      return;
    }

    setState(() {
      selectedRentalPeriods[newRentalPeriod!] = priceController.text;
      newRentalPeriod = null;
      priceController.clear();
    });
  }

  Future<void> addItem() async {
    if (nameController.text.isEmpty) return showError("Enter item name");
    if (selectedCategory == null) return showError("Select category");
    if (selectedSubCategory == null) return showError("Select sub category");
    if (pickedImages.isEmpty) return showError("Add at least one image");
    if (selectedRentalPeriods.isEmpty) return showError("Add rental periods");

    try {
      final ownerId = FirebaseAuth.instance.currentUser!.uid;
      final itemRef =
      FirebaseFirestore.instance.collection("pending_items").doc();
      String itemId = itemRef.id;

      List<String> downloadUrls = [];
      for (int i = 0; i < pickedImages.length; i++) {
        String url = await StorageService.uploadItemImage(
          ownerId,
          itemId,
          pickedImages[i],
          "photo_$i.jpg",
        );
        downloadUrls.add(url);
      }

      await itemRef.set({
        "itemId": itemId,
        "ownerId": ownerId,
        "name": nameController.text.trim(),
        "description": descController.text.trim(),
        "category": selectedCategory,
        "subCategory": selectedSubCategory,
        "images": downloadUrls,
        "rentalPeriods": selectedRentalPeriods,
        "createdAt": FieldValue.serverTimestamp(),
        "status": "pending",
      });

      showSuccess("Item submitted for approval");

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      showError("Upload error: $e");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool smallScreen = screenWidth < 360;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.item == null ? "Add New Item" : "Edit Item",
                    style: TextStyle(
                      fontSize: smallScreen ? 20 : 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildPhotoSection(),

                  const SizedBox(height: 16),

                  buildBasicInfoSection(),

                  const SizedBox(height: 16),

                  buildRentalPeriodSection(),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A005D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.item == null ? "Submit Item" : "Update Item",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhotoSection() {
    return card(
      title: "Photos",
      icon: Icons.photo_library,
      child: Column(
        children: [
          InkWell(
            onTap: pickImages,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8A005D)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text("Add Photos"),
              ),
            ),
          ),
          if (pickedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pickedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        pickedImages[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => removeImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget buildBasicInfoSection() {
    return card(
      title: "Basic Information",
      icon: Icons.info_outline,
      child: Column(
        children: [
          textField(nameController, "Item Name *"),

          const SizedBox(height: 12),

          textField(descController, "Description", maxLines: 3),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: dropdownDecoration("Category *"),
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
                selectedSubCategory = null; // reset subcategory
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedSubCategory,
            decoration: dropdownDecoration("Sub Category *"),
            items: selectedCategory == null
                ? []
                : subCategories[selectedCategory]!
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => selectedSubCategory = val),
          ),
        ],
      ),
    );
  }

  Widget buildRentalPeriodSection() {
    return card(
      title: "Rental Periods",
      icon: Icons.access_time,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: newRentalPeriod,
            decoration: dropdownDecoration("Select Rental Period"),
            items: availableRentalPeriods
                .where((p) => !selectedRentalPeriods.containsKey(p))
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => newRentalPeriod = val),
          ),

          const SizedBox(height: 10),

          textField(priceController, "Price (JD)", keyboard: TextInputType.number),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: addNewRentalPeriod,
              icon: const Icon(Icons.add),
              label: const Text("Add Rental Period"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A005D),
              ),
            ),
          ),

          if (selectedRentalPeriods.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: selectedRentalPeriods.entries.map((e) {
                return ListTile(
                  title: Text("Per ${e.key}"),
                  subtitle: Text("JD ${e.value}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeRentalPeriod(e.key),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF8A005D), width: 2),
      ),
    );
  }

  Widget textField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF8A005D), width: 2),
        ),
      ),
    );
  }

  Widget card({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF8A005D)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F0F46),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child
          ],
        ),
      ),
    );
  }
}
