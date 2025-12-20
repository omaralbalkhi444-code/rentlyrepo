
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/product_logic.dart';


void main() {
  group('ProductLogic', () {
    test('formatCategoryTitle returns correct format', () {
      expect(
        ProductLogic.formatCategoryTitle('Electronics', 'Mobiles'),
        'Electronics - Mobiles',
      );
      expect(
        ProductLogic.formatCategoryTitle('Home', 'Furniture'),
        'Home - Furniture',
      );
    });

    test('hasProducts returns true for non-empty list', () {
      expect(ProductLogic.hasProducts([1, 2, 3]), true);
    });

    test('hasProducts returns false for empty list', () {
      expect(ProductLogic.hasProducts([]), false);
    });

    test('convertToItem creates Item correctly', () {
      final data = {
        'name': 'Test Item',
        'description': 'Test Description',
        'category': 'Test Category',
        'subCategory': 'Test SubCategory',
        'ownerId': 'owner123',
        'images': ['image1.jpg', 'image2.jpg'],
        'rentalPeriods': {'day': 10, 'week': 50},
        'latitude': 31.9566,
        'longitude': 35.9457,
        'averageRating': 4.5,
        'ratingCount': 10,
        'status': 'approved',
      };

      final item = ProductLogic.convertToItem('item123', data);

      expect(item.id, 'item123');
      expect(item.name, 'Test Item');
      expect(item.description, 'Test Description');
      expect(item.category, 'Test Category');
      expect(item.subCategory, 'Test SubCategory');
      expect(item.ownerId, 'owner123');
      expect(item.images, ['image1.jpg', 'image2.jpg']);
      expect(item.rentalPeriods, {'day': 10, 'week': 50});
      expect(item.latitude, 31.9566);
      expect(item.longitude, 35.9457);
      expect(item.averageRating, 4.5);
      expect(item.ratingCount, 10);
      expect(item.status, 'approved');
    });

    test('convertToItem handles missing data', () {
      final data = {
        'name': 'Test Item',
        'description': '',
      };

      final item = ProductLogic.convertToItem('item123', data);

      expect(item.id, 'item123');
      expect(item.name, 'Test Item');
      expect(item.description, '');
      expect(item.category, '');
      expect(item.subCategory, '');
      expect(item.ownerId, '');
      expect(item.images, isEmpty);
      expect(item.rentalPeriods, isEmpty);
      expect(item.latitude, isNull);
      expect(item.longitude, isNull);
      expect(item.averageRating, 0.0);
      expect(item.ratingCount, 0);
      expect(item.status, 'approved');
    });

    test('getPriceText returns correct text for empty rental', () {
      expect(ProductLogic.getPriceText({}), 'No rental price');
    });

    test('getPriceText returns correct text for non-empty rental', () {
      expect(
        ProductLogic.getPriceText({'day': 10}),
        'From JOD 10 / day',
      );
      expect(
        ProductLogic.getPriceText({'week': 50}),
        'From JOD 50 / week',
      );
    });

    test('formatRentalPeriods returns formatted list', () {
      final rental = {'day': 10, 'week': 50, 'month': 200};
      final result = ProductLogic.formatRentalPeriods(rental);

      expect(result.length, 3);
      expect(result[0], 'day: 10 JOD');
      expect(result[1], 'week: 50 JOD');
      expect(result[2], 'month: 200 JOD');
    });

    test('formatRentalPeriods returns empty list for empty rental', () {
      final result = ProductLogic.formatRentalPeriods({});
      expect(result, isEmpty);
    });

    test('validateItemData returns true for valid data', () {
      final validData = {
        'name': 'Item',
        'category': 'Category',
        'subCategory': 'SubCategory',
      };
      expect(ProductLogic.validateItemData(validData), true);
    });

    test('validateItemData returns false for missing name', () {
      final invalidData = {
        'category': 'Category',
        'subCategory': 'SubCategory',
      };
      expect(ProductLogic.validateItemData(invalidData), false);
    });

    test('validateItemData returns false for missing category', () {
      final invalidData = {
        'name': 'Item',
        'subCategory': 'SubCategory',
      };
      expect(ProductLogic.validateItemData(invalidData), false);
    });

    test('validateItemData returns false for missing subCategory', () {
      final invalidData = {
        'name': 'Item',
        'category': 'Category',
      };
      expect(ProductLogic.validateItemData(invalidData), false);
    });

    test('validateItemData returns false for empty data', () {
      expect(ProductLogic.validateItemData({}), false);
    });

    test('filterProductsSimple filters correctly', () {
      final mockProducts = [
        {'name': 'iPhone', 'category': 'Electronics'},
        {'name': 'Samsung', 'category': 'Electronics'},
        {'name': 'Dell Laptop', 'category': 'Electronics'},
      ];
      
      final result = ProductLogic.filterProductsSimple(mockProducts, 'phone');
      expect(result.length, 1);
      expect(result[0]['name'], 'iPhone');
    });

    test('filterProductsSimple handles case insensitive search', () {
      final mockProducts = [
        {'name': 'iPhone', 'category': 'Electronics'},
        {'name': 'Samsung', 'category': 'Electronics'},
      ];
      
      final result = ProductLogic.filterProductsSimple(mockProducts, 'IPHONE');
      expect(result.length, 1);
      expect(result[0]['name'], 'iPhone');
    });

    test('filterProductsSimple returns empty for no match', () {
      final mockProducts = [
        {'name': 'iPhone', 'category': 'Electronics'},
        {'name': 'Samsung', 'category': 'Electronics'},
      ];
      
      final result = ProductLogic.filterProductsSimple(mockProducts, 'xyz');
      expect(result, isEmpty);
    });

    test('filterProductsSimple handles partial matches', () {
      final mockProducts = [
        {'name': 'iPhone', 'category': 'Electronics'},
        {'name': 'Samsung', 'category': 'Electronics'},
        {'name': 'Dell Laptop', 'category': 'Electronics'},
      ];
      
      final result = ProductLogic.filterProductsSimple(mockProducts, 'lap');
      expect(result.length, 1);
      expect(result[0]['name'], 'Dell Laptop');
    });

    test('filterProductsSimple returns all when search query is empty', () {
      final mockProducts = [
        {'name': 'iPhone', 'category': 'Electronics'},
        {'name': 'Samsung', 'category': 'Electronics'},
      ];
      
      final result = ProductLogic.filterProductsSimple(mockProducts, '');
      expect(result.length, 2);
    });
  });

  group('ProductLogic Additional Tests', () {
    test('handles null name in data', () {
      final data = {
        'name': null,
        'description': 'Test',
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.name, '');
      expect(item.description, 'Test');
    });

    test('handles numeric rental periods', () {
      final data = {
        'name': 'Test',
        'rentalPeriods': {'day': 10, 'week': 50.5},
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.rentalPeriods, {'day': 10, 'week': 50.5});
    });

    test('getPriceText handles string price', () {
      expect(
        ProductLogic.getPriceText({'day': '10'}),
        'From JOD 10 / day',
      );
    });

    test('formatRentalPeriods handles different data types', () {
      final rental = {'day': 10, 'week': '50', 'month': 200.0};
      final result = ProductLogic.formatRentalPeriods(rental);
      
      expect(result.length, 3);
      expect(result[0], 'day: 10 JOD');
      expect(result[1], 'week: 50 JOD');
      expect(result[2], 'month: 200.0 JOD');
    });

    test('handles null images list', () {
      final data = {
        'name': 'Test',
        'images': null,
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.images, isEmpty);
    });

    test('handles null rental periods', () {
      final data = {
        'name': 'Test',
        'rentalPeriods': null,
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.rentalPeriods, isEmpty);
    });

    test('handles double averageRating', () {
      final data = {
        'name': 'Test',
        'averageRating': 4.7,
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.averageRating, 4.7);
    });

    test('handles int averageRating', () {
      final data = {
        'name': 'Test',
        'averageRating': 5,
      };
      final item = ProductLogic.convertToItem('test123', data);
      expect(item.averageRating, 5.0);
    });
  });
}
