class FavouriteManager {
  static List<String> favouriteIds = [];

  static bool isFavourite(String itemId) {
    return favouriteIds.contains(itemId);
  }

  static void add(String itemId) {
    if (!favouriteIds.contains(itemId)) {
      favouriteIds.add(itemId);
    }
  }

  static void remove(String itemId) {
    favouriteIds.remove(itemId);
  }
}
