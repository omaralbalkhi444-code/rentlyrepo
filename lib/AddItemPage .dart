import 'dart:io';
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
      final userId = "tempOwnerId"; // TODO: Replace with FirebaseAuth.instance.currentUser!.uid

      List<String> downloadUrls = [];
      for (int i = 0; i < pickedImages.length; i++) {
        String url = await StorageService.uploadItemImage(
          userId,
          pickedImages[i],
          "item_$i.jpg",
        );
        downloadUrls.add(url);
      }

      await FirestoreService.submitItemForApproval(
        ownerId: userId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        pricePerHour: double.parse(pricePerHourController.text),
        pricePerWeek: double.parse(pricePerWeekController.text),
        pricePerMonth: double.parse(pricePerMonthController.text),
        pricePerYear: double.parse(pricePerYearController.text),
        category: selectedCategory!,
        imageUrls: downloadUrls,
      );

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? "Add New Item" : "Edit Item"),
        backgroundColor: const Color(0xFF8A005D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Images",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: pickImages,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 30, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          "Add Images (${pickedImages.length})",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                if (pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pickedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(pickedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                  onPressed: () => removeImage(index),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            
            const Text(
              "Prices (Required for all periods):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: pricePerHourController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price per hour (JD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pricePerWeekController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price per week (JD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pricePerMonthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price per month (JD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pricePerYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price per year (JD)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A005D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.item == null ? "Add Item" : "Update Item",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
