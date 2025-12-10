import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'AddItemPage .dart';
import 'bottom_nav.dart';

class OwnerItemsPage extends StatefulWidget {
  const OwnerItemsPage({super.key});

  @override
  State<OwnerItemsPage> createState() => _OwnerItemsPageState();
}

class _OwnerItemsPageState extends State<OwnerItemsPage> {
  int selectedTab = 0;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(size, isSmall),
          SizedBox(height: size.height * 0.02),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab("My Items", 0, size.width),
              SizedBox(width: isSmall ? 20 : 40),
              _buildTab("Requests", 1, size.width),
            ],
          ),

          SizedBox(height: size.height * 0.03),

          Expanded(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: const SharedBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeader(Size size, bool isSmall) {
    return ClipPath(
      clipper: SideCurveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: size.height * 0.06,
          bottom: size.height * 0.07,
          left: size.width * 0.05,
          right: size.width * 0.05,
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
            const SizedBox(width: 30),
            Text(
              "My Items",
              style: TextStyle(
                fontSize: isSmall ? 20 : 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: isSmall ? 24 : 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddItemPage(item: null),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index, double screenWidth) {
    bool active = selectedTab == index;
    bool isSmall = screenWidth < 380;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 18,
          vertical: isSmall ? 8 : 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? const Color(0xFF8A005D) : Colors.black,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(25),
          color: active ? Colors.white : Colors.transparent,
        ),
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            color: active ? const Color(0xFF8A005D) : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTab == 0) {
      return _buildMyItems();
    } else {
      return _buildIncomingRequests();
    }
  }

  Widget _buildMyItems() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("items")
          .where("ownerId", isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "You haven't listed any items yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildItemCard(data);
          }).toList(),
        );
      },
    );
  }

  Widget _buildIncomingRequests() {
    return const Center(
      child: Text(
        "Requests feature coming later.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> data) {
    final images = List<String>.from(data["images"] ?? []);
    final rental = Map<String, dynamic>.from(data["rentalPeriods"] ?? {});

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(12),
        title: Text(
          data["name"] ?? "No name",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${data["category"]} → ${data["subCategory"]}"),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Description: ${data["description"] ?? ""}"),
                const SizedBox(height: 10),

                if (images.isNotEmpty) ...[
                  const Text("Images:",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: images
                          .map((url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            height: 110,
                            width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                if (rental.isNotEmpty) ...[
                  const Text("Rental Periods:",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...rental.entries.map(
                        (entry) => Text(
                      "• ${entry.key}: JOD ${entry.value}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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
