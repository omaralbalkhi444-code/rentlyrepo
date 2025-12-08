import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2/Categories_Page.dart';
import 'EquipmentItem.dart';
import 'package:p2/services/storage_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, this.item});

  final EquipmentItem? item;

  @override
  // ignore: library_private_types_in_public_api
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  
  
  final Map<String, String> selectedRentalPeriods = {};
  
  
  String? newRentalPeriod;
  final TextEditingController priceController = TextEditingController();
  
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

  
  final List<String> availableRentalPeriods = [
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFiles != null) {
      setState(() {
  
        int remainingSlots = 5 - pickedImages.length;
        if (remainingSlots > 0) {
          int imagesToAdd = pickedFiles.length > remainingSlots 
              ? remainingSlots 
              : pickedFiles.length;
          
          pickedImages.addAll(
            pickedFiles.take(imagesToAdd).map((file) => File(file.path)).toList()
          );
        }
        
        if (pickedFiles.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 images allowed. Added $remainingSlots images.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      pickedImages.removeAt(index);
    });
  }

  void removeRentalPeriod(String period) {
    setState(() {
      selectedRentalPeriods.remove(period);
    });
  }

  void addNewRentalPeriod() {
    if (newRentalPeriod == null || priceController.text.isEmpty) {
      showErrorSnackBar('Please select a period and enter price');
      return;
    }
    
    final price = double.tryParse(priceController.text);
    if (price == null || price <= 0) {
      showErrorSnackBar('Please enter a valid price');
      return;
    }
    
    
    if (selectedRentalPeriods.containsKey(newRentalPeriod)) {
      showErrorSnackBar('$newRentalPeriod is already added');
      return;
    }
    
    setState(() {
      selectedRentalPeriods[newRentalPeriod!] = priceController.text;
      priceController.clear();
      newRentalPeriod = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $newRentalPeriod rental for JD ${price.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> addItem() async {
  
    if (nameController.text.isEmpty) {
      showErrorSnackBar('Please enter item name');
      return;
    }
    
    if (selectedCategory == null) {
      showErrorSnackBar('Please select a category');
      return;
    }
    
    if (pickedImages.isEmpty) {
      showErrorSnackBar('Please add at least one image');
      return;
    }
    
    if (selectedRentalPeriods.isEmpty) {
      showErrorSnackBar('Please add at least one rental period');
      return;
    }

    try {
      final ownerId = FirebaseAuth.instance.currentUser!.uid;
      final itemRef = FirebaseFirestore.instance.collection("pending_items").doc();
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

    
      Map<String, dynamic> itemData = {
        "itemId": itemId,
        "ownerId": ownerId,
        "name": nameController.text.trim(),
        "description": descController.text.trim().isNotEmpty 
            ? descController.text.trim() 
            : "",
        "category": selectedCategory,
        "images": downloadUrls,
        "rentalPeriods": selectedRentalPeriods,
        "createdAt": FieldValue.serverTimestamp(),
        "status": "pending",
      };

      
      await itemRef.set(itemData);

      showSuccessSnackBar('Item submitted for approval');
      
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
      
    } catch (e) {
      showErrorSnackBar('Error uploading item: $e');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

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
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 28,
                  ),
                    onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(),
      ),
    );
  },

                ),
               const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.item == null ? "Add New Item" : "Edit Item",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                               const Icon(Icons.photo_library, color: Color(0xFF8A005D)),
                               const SizedBox(width: 8),
                                const Text(
                                  "Photos",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "${pickedImages.length}/5",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            
                        
                            InkWell(
                              onTap: pickImages,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color(0xFF8A005D).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 32,
                                      color: Color(0xFF8A005D).withOpacity(0.7),
                                    ),
                                    SizedBox(height: 8),
                                    const Text(
                                      "Add Photos",
                                      style: TextStyle(
                                        color: Color(0xFF8A005D),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                        
                            if (pickedImages.isNotEmpty) ...[
                              SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics:const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: pickedImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
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
                                        child: GestureDetector(
                                          onTap: () => removeImage(index),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF8A005D)),
                                SizedBox(width: 8),
                                Text(
                                  "Basic Information",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Item Name *",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                            SizedBox(height: 12),

                        
                            TextField(
                              controller: descController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Description",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                contentPadding:const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                           const SizedBox(height: 12),

                        
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Category *",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                ),
                                contentPadding:const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              value: selectedCategory,
                              items: categories
                                  .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: TextStyle(fontSize: 14)),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                              hint:const Text("Select category"),
                            ),
                          ],
                        ),
                      ),
                    ),

                   const SizedBox(height: 16),

                   
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: Color(0xFF8A005D)),
                                SizedBox(width: 8),
                                Text(
                                  "Add Rental Periods",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F0F46),
                                  ),
                                ),
                              ],
                            ),
                           const SizedBox(height: 12),
                            
                        
                            Container(
                              padding:const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                
                                  DropdownButtonFormField<String>(
                                    value: newRentalPeriod,
                                    decoration: const InputDecoration(
                                      labelText: "Select Rental Period",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    items: availableRentalPeriods
                                        .where((period) => !selectedRentalPeriods.containsKey(period))
                                        .map((period) => DropdownMenuItem(
                                              value: period,
                                              child: Text(
                                                " $period",
                                                style:const TextStyle(fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        newRentalPeriod = value;
                                      });
                                    },
                                    hint:const Text("Choose period"),
                                  ),
                                  
                                 const SizedBox(height: 12),
                                  
                                
                                  TextField(
                                    controller: priceController,
                                    keyboardType:const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: "Price (JD)",
                                      
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:const BorderSide(color: Color(0xFF8A005D), width: 2),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: addNewRentalPeriod,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF8A005D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon:const Icon(Icons.add, size: 20, color: Colors.white),
                                      label: const Text(
                                        "Add This Rental Period",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  
                    if (selectedRentalPeriods.isNotEmpty) ...[
                     const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding:const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                 const Icon(Icons.check_circle, color: Colors.green),
                                 const SizedBox(width: 8),
                                  const Text(
                                    "Added Rental Periods",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F0F46),
                                    ),
                                  ),
                                 const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF8A005D).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${selectedRentalPeriods.length} added",
                                      style: const TextStyle(
                                        color: Color(0xFF8A005D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                             const SizedBox(height: 12),
                              
                        
                              ListView.separated(
                                shrinkWrap: true,
                                physics:const NeverScrollableScrollPhysics(),
                                itemCount: selectedRentalPeriods.length,
                                separatorBuilder: (context, index) => Divider(height: 8),
                                itemBuilder: (context, index) {
                                  final period = selectedRentalPeriods.keys.elementAt(index);
                                  final price = selectedRentalPeriods[period]!;
                                  
                                  return Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                       const Icon(Icons.schedule, color: Color(0xFF8A005D)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Per $period",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                             const SizedBox(height: 4),
                                              Text(
                                                "JD ${price}",
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => removeRentalPeriod(period),
                                          icon: Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: "Remove",
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (selectedRentalPeriods.isEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.amber[700], size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Rental Periods",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Use the 'Add Rental Periods' section above to add hourly, daily, weekly, monthly, or yearly rental options.",
                                    style: TextStyle(
                                      color: Colors.amber[800],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                  
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8A005D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          shadowColor: Color(0xFF8A005D).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.item == null ? Icons.add : Icons.save,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              widget.item == null ? "Submit Item" : "Update Item",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
