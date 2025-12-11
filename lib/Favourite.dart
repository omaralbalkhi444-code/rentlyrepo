import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FavouriteManager.dart';

class FavouritePage extends StatefulWidget {
  static const routeName = '/favorites';

  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    final favIds = FavouriteManager.favouriteIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite"),
      ),
      body: favIds.isEmpty
          ? const Center(
        child: Text(
          "Your favourite items will appear here.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("approved_items")
            .where("itemId", whereIn: favIds)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No favourite items found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 3 / 4,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final image = data["images"]?.isNotEmpty == true
                  ? data["images"][0]
                  : null;

              final name = data["name"] ?? "Item";

              final rental = Map<String, dynamic>.from(
                data["rentalPeriods"] ?? {},
              );

              final hourlyPrice =
              rental.containsKey("Hourly") ? rental["Hourly"] : null;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    FavouriteManager.remove(data["itemId"]);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.image, size: 60),

                      const SizedBox(height: 10),

                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        hourlyPrice != null
                            ? "JOD $hourlyPrice / hour"
                            : "No hourly price",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Tap to remove",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
