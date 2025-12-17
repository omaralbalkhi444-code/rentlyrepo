import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2/pick_location_page.dart';
import 'package:p2/services/storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, this.existingItem});

  final Map<String, dynamic>? existingItem;

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCategory;
  String? selectedSubCategory;

  double? latitude;
  double? longitude;

  Map<String, dynamic> rentalPeriods = {};
  String? newRentalPeriod;

  List<File> pickedImages = [];
  List<String> existingImageUrls = [];

  final categories = [
    "Electronics",
    "Computers & Mobiles",
    "Video Games",
    "Sports",
    "Tools & Devices",
    "Home & Garden",
    "Fashion & Clothing",
  ];

  final subCategories = {
    "Electronics": ["Cameras & Photography", "Audio & Video"],
    "Computers & Mobiles": [
      "Mobiles",
      "Laptops",
      "Printers",
      "Projectors",
      "Servers"
    ],
    "Video Games": ["Gaming Devices"],
    "Sports": ["Bicycle", "Books", "Skates & Scooters", "Camping"],
    "Tools & Devices": [
      "Maintenance Tools",
      "Medical Devices",
      "Cleaning Equipment"
    ],
    "Home & Garden": ["Garden Equipment", "Home Supplies"],
    "Fashion & Clothing": ["Men", "Women", "Customs", "Baby Supplies"],
  };

  final availableRentalPeriods = [
    "Hourly",
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly"
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingItem != null) {
      final data = widget.existingItem!;
      nameController.text = data["name"] ?? "";
      descController.text = data["description"] ?? "";
      selectedCategory = data["category"];
      selectedSubCategory = data["subCategory"];
      rentalPeriods = Map<String, dynamic>.from(data["rentalPeriods"] ?? {});
      existingImageUrls = List<String>.from(data["images"] ?? []);
    }
  }

  Future<void> pickImages() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (images != null) {
      setState(() {
        pickedImages.addAll(images.map((i) => File(i.path)));
      });
    }
  }

  void removeImage(int index) {
    setState(() => pickedImages.removeAt(index));
  }

  void removeExistingImage(String url) {
    setState(() => existingImageUrls.remove(url));
  }

  void addRentalPeriod() {
    if (newRentalPeriod == null || priceController.text.isEmpty) {
      showError("Please select a rental period and enter a price.");
      return;
    }

    rentalPeriods[newRentalPeriod!] = priceController.text;
    newRentalPeriod = null;
    priceController.clear();
    setState(() {});
  }

  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationPage()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
    }
  }

  Future<void> saveItem() async {
    if (nameController.text.isEmpty) return showError("Enter item name");
    if (selectedCategory == null) return showError("Select category");
    if (selectedSubCategory == null) return showError("Select sub category");
    if (rentalPeriods.isEmpty) return showError("Add rental periods");

    try {
      final ownerId = FirebaseAuth.instance.currentUser!.uid;

      final isEditing = widget.existingItem != null;

      final docRef = isEditing
          ? FirebaseFirestore.instance
          .collection("pending_items")
          .doc(widget.existingItem!["itemId"])
          : FirebaseFirestore.instance.collection("pending_items").doc();

      final itemId = docRef.id;

      List<String> uploadedUrls = [];
      for (int i = 0; i < pickedImages.length; i++) {
        final url = await StorageService.uploadItemImage(
          ownerId,
          itemId,
          pickedImages[i],
          "photo_$i.jpg",
        );
        uploadedUrls.add(url);
      }

      final allImages = [...existingImageUrls, ...uploadedUrls];

      await docRef.set({
        "itemId": itemId,
        "ownerId": ownerId,
        "name": nameController.text.trim(),
        "description": descController.text.trim(),
        "category": selectedCategory,
        "subCategory": selectedSubCategory,
        "images": allImages,
        "rentalPeriods": rentalPeriods,
        "status": "pending",
        "latitude": latitude,
        "longitude": longitude,
        "createdAt": FieldValue.serverTimestamp(),
      });

      showSuccess(isEditing ? "Item updated" : "Item submitted for approval");

      Navigator.pop(context);

    } catch (e) {
      showError("Error: $e");
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
    final smallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      body: Column(
        children: [
          buildHeader(smallScreen),
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
                  const SizedBox(height: 16),
                  buildLocationSection(),
                  const SizedBox(height: 25),
                  buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(bool smallScreen) {
    return Container(
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
              widget.existingItem == null ? "Add New Item" : "Edit Item",
              style: TextStyle(
                fontSize: smallScreen ? 20 : 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
      icon: Icons.photo,
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
              child: const Center(child: Text("Add Photos")),
            ),
          ),

          if (existingImageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: existingImageUrls.map((url) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => removeExistingImage(url),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],

          if (pickedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: pickedImages.map((file) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                      Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                    ),
                  ],
                );
              }).toList(),
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
            items:
            categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
                selectedSubCategory = null;
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
                .where((rp) => !rentalPeriods.containsKey(rp))
                .map((rp) => DropdownMenuItem(value: rp, child: Text(rp)))
                .toList(),
            onChanged: (val) => setState(() => newRentalPeriod = val),
          ),

          const SizedBox(height: 10),
          textField(priceController, "Price (JD)", keyboard: TextInputType.number),
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: addRentalPeriod,
            icon: const Icon(Icons.add),
            label: const Text("Add Period"),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8A005D)),
          ),

          const SizedBox(height: 10),

          Column(
            children: rentalPeriods.entries.map((e) {
              return ListTile(
                title: Text("${e.key}"),
                subtitle: Text("JD ${e.value}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => rentalPeriods.remove(e.key));
                  },
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget buildLocationSection() {
    return card(
      title: "Location",
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            latitude == null || longitude == null
                ? "No location selected"
                : "Lat: $latitude\nLng: $longitude",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: pickLocation,
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8A005D)),
            child: const Text("Pick Location"),
          ),
        ],
      ),
    );
  }

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: saveItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8A005D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          widget.existingItem == null ? "Submit Item" : "Update Item",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  InputDecoration dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget textField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget card({required String title, required IconData icon, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF8A005D)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F0F46)),
                )
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
 
