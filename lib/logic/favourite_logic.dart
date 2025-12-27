
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2/FavouriteManager.dart';

class FavouriteLogic {
  List<String> get favouriteIds => FavouriteManager.favouriteIds;

  bool get hasFavourites => FavouriteManager.favouriteIds.isNotEmpty;

  String get emptyMessage => "Your favourite items will appear here.";

  String get noItemsMessage => "No favourite items found.";

  Future<List<Map<String, dynamic>>> getFavouriteItems() async {
    if (!hasFavourites) {
      return [];
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("approved_items")
          .where("itemId", whereIn: favouriteIds)
          .get();

      final items = <Map<String, dynamic>>[];
      
      for (final doc in querySnapshot.docs) {
        items.add(doc.data());
      }
      
      return items;
    } catch (e) {
      return [];
    }
  }

  String getItemName(Map<String, dynamic> data) {
    return data["name"]?.toString() ?? "Item";
  }

  String? getItemImage(Map<String, dynamic> data) {
    final images = data["images"];
    if (images is List && images.isNotEmpty) {
      return images[0]?.toString();
    }
    return null;
  }

  String getItemPriceText(Map<String, dynamic> data) {
    final rental = data["rentalPeriods"];
    if (rental is Map && rental.containsKey("Hourly")) {
      final price = rental["Hourly"];
      return "JOD $price / hour";
    }
    return "No hourly price";
  }

  String getItemId(Map<String, dynamic> data) {
    return data["itemId"]?.toString() ?? "";
  }

  void removeFavourite(String itemId) {
    FavouriteManager.remove(itemId);
  }
}
