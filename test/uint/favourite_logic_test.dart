
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/favourite_logic.dart';

void main() {
  group('FavouriteLogic Tests', () {
    test('hasFavourites returns correct value', () {
      final logic = FavouriteLogic();
      
      expect(logic.hasFavourites, isA<bool>());
    });

    test('emptyMessage returns correct text', () {
      final logic = FavouriteLogic();
      expect(logic.emptyMessage, "Your favourite items will appear here.");
    });

    test('noItemsMessage returns correct text', () {
      final logic = FavouriteLogic();
      expect(logic.noItemsMessage, "No favourite items found.");
    });

    test('getItemName returns correct name', () {
      final logic = FavouriteLogic();
      final testData = {"name": "Test Item", "itemId": "123"};
      expect(logic.getItemName(testData), "Test Item");
    });

    test('getItemName returns default when null', () {
      final logic = FavouriteLogic();
      final testData = {"itemId": "123"};
      expect(logic.getItemName(testData), "Item");
    });

    test('getItemImage returns correct image URL', () {
      final logic = FavouriteLogic();
      final testData = {"images": ["image1.jpg", "image2.jpg"]};
      expect(logic.getItemImage(testData), "image1.jpg");
    });

    test('getItemPriceText returns hourly price when available', () {
      final logic = FavouriteLogic();
      final testData = {
        "rentalPeriods": {"Hourly": 15.0}
      };
      expect(logic.getItemPriceText(testData), "JOD 15.0 / hour");
    });

    test('getItemPriceText returns default when no hourly price', () {
      final logic = FavouriteLogic();
      final testData = {"rentalPeriods": {}};
      expect(logic.getItemPriceText(testData), "No hourly price");
    });
  });
}
