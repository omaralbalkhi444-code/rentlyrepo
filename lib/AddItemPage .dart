import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p2/services/firestore_service.dart';
import 'package:p2/services/storage_service.dart';
import 'EquipmentItem.dart';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, this.item});

  final EquipmentItem? item;

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController pricePerHourController = TextEditingController();
  final TextEditingController pricePerWeekController = TextEditingController();
  final TextEditingController pricePerMonthController = TextEditingController();
  final TextEditingController pricePerYearController = TextEditingController();

  String? selectedCategory;
  List<File> pickedImages = [];

  final List<String> categories = [
    "Electronics",
    "Computers & Technology",
    "Sports & Camping",
    "Tools & Equipment",
    "Garden & Home",
    "Clothing & Fashion",
    "Others"
  ];

  Future pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    
    if (pickedFiles != null) {
      setState(() {
        pickedImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      pickedImages.removeAt(index);
    });
  }

  Future<void> addItem() async {
    if (nameController.text.isEmpty ||
        descController.text.isEmpty ||
        selectedCategory == null ||
        pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (pricePerHourController.text.isEmpty ||
        pricePerWeekController.text.isEmpty ||
        pricePerMonthController.text.isEmpty ||
        pricePerYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all prices")),
      );
      return;
    }

    try {
      final ownerId = FirebaseAuth.instance.currentUser!.uid;

      final itemRef = FirebaseFirestore.instance.collection("items").doc();
      final String itemId = itemRef.id;

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

      await FirestoreService.submitItemForApproval(
        ownerId: ownerId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        pricePerHour: double.parse(pricePerHourController.text),
        pricePerWeek: double.parse(pricePerWeekController.text),
        pricePerMonth: double.parse(pricePerMonthController.text),
        pricePerYear: double.parse(pricePerYearController.text),
        category: selectedCategory!,
        imageUrls: downloadUrls,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item submitted for approval")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading item: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: Column(
        children: [
        
          ClipPath(
            clipper: SideCurveClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: screenHeight * 0.06,
                bottom: screenHeight * 0.06,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.item == null ? "Add New Item" : "Edit Item",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40), 
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.photo_library, color: Color(0xFF8A005D)),
                                SizedBox(width: 10),
                                Text(
                                  "Images",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: pickImages,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF8A005D).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Color(0xFF8A005D).withOpacity(0.7),
                                    ),
                                   const SizedBox(height: 8),
                                    const Text(
                                      "Tap to add images",
                                      style: TextStyle(
                                        color: Color(0xFF8A005D),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (pickedImages.isNotEmpty)
                                      Text(
                                        "(${pickedImages.length} selected)",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (pickedImages.isNotEmpty) ...[
                             const SizedBox(height: 16),
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pickedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: FileImage(pickedImages[index]),
                                                fit: BoxFit.cover,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 5,
                                                  offset:const Offset(0, 3),
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: -5,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.red,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon:const Icon(Icons.close, size: 16, color: Colors.white),
                                                onPressed: () => removeImage(index),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF8A005D)),
                                SizedBox(width: 10),
                                Text(
                                  "Item Details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                              ],
                            ),
                           const SizedBox(height: 16),
                            
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Item Name",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                prefixIcon:const Icon(Icons.photo_camera_back, color: Color(0xFF8A005D)),
                              ),
                            ),
                           const SizedBox(height: 15),
                            
                            TextField(
                              controller: descController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Description",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                prefixIcon:const Icon(Icons.description, color: Color(0xFF8A005D)),
                              ),
                            ),
                           const SizedBox(height: 15),
                            
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Category",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                prefixIcon:const Icon(Icons.category, color: Color(0xFF8A005D)),
                              ),
                              initialValue: selectedCategory,
                              items: categories
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat, style: const TextStyle(fontSize: 16)),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                   const SizedBox(height: 20),
                    
                  
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.monetization_on, color: Color(0xFF8A005D)),
                                SizedBox(width: 10),
                                Text(
                                  "Rental Prices (JD)",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                              ],
                            ),
                           const SizedBox(height: 16),
                            
                            GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 3,
                              shrinkWrap: true,
                              physics:const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: [
                                _buildPriceField("Hour", pricePerHourController, Icons.access_time),
                                _buildPriceField("Week", pricePerWeekController, Icons.calendar_today),
                                _buildPriceField("Month", pricePerMonthController, Icons.date_range),
                                _buildPriceField("Year", pricePerYearController, Icons.calendar_view_month),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                   const SizedBox(height: 30),
                    
              
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: const Color(0xFF8A005D).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.item == null ? Icons.add_circle_outline : Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                         const SizedBox(width: 10),
                            Text(
                              widget.item == null ? "Add Item" : "Update Item",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: "Price per $label",
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8A005D), width: 2),
        ),
        prefixIcon: Icon(icon, color: Color(0xFF8A005D), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class SideCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 40;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.arcToPoint(
      Offset(radius, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width - radius, size.height - radius);
    path.arcToPoint(
      Offset(size.width, size.height),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
