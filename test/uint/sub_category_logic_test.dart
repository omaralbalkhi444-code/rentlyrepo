
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:p2/logic/sub_category_logic.dart';


void main() {
  group('SubCategoryLogic Tests', () {
    test('getSubCategories - returns correct list for existing category', () {
    
      const categoryId = "c2";
      
    
      final result = SubCategoryLogic.getSubCategories(categoryId);
      
    
      expect(result.length, 5);
      expect(result[0]['title'], 'Mobiles');
      expect(result[0]['icon'], Icons.phone_android);
    });

    test('getSubCategories - returns empty list for non-existing category', () {
    
      const categoryId = "non_existing";
      
    
      final result = SubCategoryLogic.getSubCategories(categoryId);
      
   
      expect(result, isEmpty);
    });

    test('getSubCategoryCount - returns correct count', () {
   
      expect(SubCategoryLogic.getSubCategoryCount("c1"), 2);
      expect(SubCategoryLogic.getSubCategoryCount("c3"), 1);
      expect(SubCategoryLogic.getSubCategoryCount("invalid"), 0);
    });

    test('hasSubCategories - returns correct boolean', () {
     
      expect(SubCategoryLogic.hasSubCategories("c1"), true);
      expect(SubCategoryLogic.hasSubCategories("invalid"), false);
    });

    test('getSubCategoryTitle - returns correct title', () {
      
      expect(SubCategoryLogic.getSubCategoryTitle("c1", 0), "Cameras & Photography");
      expect(SubCategoryLogic.getSubCategoryTitle("c1", 1), "Audio & Video");
      expect(SubCategoryLogic.getSubCategoryTitle("c1", 5), ""); 
      expect(SubCategoryLogic.getSubCategoryTitle("invalid", 0), "");
    });

    test('getSubCategoryIcon - returns correct icon', () {
      
      expect(SubCategoryLogic.getSubCategoryIcon("c1", 0), Icons.photo_camera);
      expect(SubCategoryLogic.getSubCategoryIcon("c2", 0), Icons.phone_android);
      expect(SubCategoryLogic.getSubCategoryIcon("invalid", 0), Icons.error);
    });

    test('getAllCategoryIds - returns all category IDs', () {
      
      const expectedIds = ["c1", "c2", "c3", "c4", "c5", "c6", "c7"];
      
     
      final result = SubCategoryLogic.getAllCategoryIds();
      
      
      expect(result.length, 7);
      expect(result, containsAll(expectedIds));
    });

    test('categoryExists - returns correct boolean', () {
     
      expect(SubCategoryLogic.categoryExists("c1"), true);
      expect(SubCategoryLogic.categoryExists("c2"), true);
      expect(SubCategoryLogic.categoryExists("invalid"), false);
    });

    test('searchSubCategories - finds matching results', () {
      
      const query = "Mobi";
      
      
      final results = SubCategoryLogic.searchSubCategories(query);
      
     
      expect(results.length, greaterThan(0));
      expect(results[0]['title'], contains('Mobi'));
    });

    test('searchSubCategories - is case insensitive', () {
    
      const query = "mobi";
      
      
      final results = SubCategoryLogic.searchSubCategories(query);
      
   
      expect(results.length, greaterThan(0));
    });

    test('searchSubCategories - returns empty for no match', () {
      
      const query = "xyz123";
      
     
      final results = SubCategoryLogic.searchSubCategories(query);
      
      
      expect(results, isEmpty);
    });
  });
}
