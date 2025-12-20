
import 'package:flutter/material.dart';

class SubCategoryLogic {
  
  static final Map<String, List<Map<String, dynamic>>> subCategoryData = {
    "c1": [
      {"title": "Cameras & Photography", "icon": Icons.photo_camera},
      {"title": "Audio & Video", "icon": Icons.speaker},
    ],
    "c2": [
      {"title": "Mobiles", "icon": Icons.phone_android},
      {"title": "Laptops", "icon": Icons.laptop_mac},
      {"title": "Printers", "icon": Icons.print},
      {"title": "Projectors", "icon": Icons.video_camera_back},
      {"title": "Servers", "icon": Icons.dns},
    ],
    "c3": [
      {"title": "Gaming Devices", "icon": Icons.sports_esports},
    ],
    "c4": [
      {"title": "Bicycles", "icon": Icons.pedal_bike},
      {"title": "Books", "icon": Icons.menu_book},
      {"title": "Skates & Scooters", "icon": Icons.roller_skating_outlined},
      {"title": "Camping", "icon": Icons.park},
    ],
    "c5": [
      {"title": "Maintenance Tools", "icon": Icons.build},
      {"title": "Medical Devices", "icon": Icons.monitor_heart},
      {"title": "Cleaning Equipment", "icon": Icons.cleaning_services},
    ],
    "c6": [
      {"title": "Garden Equipment", "icon": Icons.yard_outlined},
      {"title": "Home Supplies", "icon": Icons.home},
    ],
    "c7": [
      {"title": "Men", "icon": Icons.man},
      {"title": "Women", "icon": Icons.woman},
      {"title": "Customs", "icon": Icons.checkroom},
      {"title": "Baby Supplies", "icon": Icons.child_friendly},
    ],
  };

  static List<Map<String, dynamic>> getSubCategories(String categoryId) {
    return subCategoryData[categoryId] ?? [];
  }

  
  static int getSubCategoryCount(String categoryId) {
    return subCategoryData[categoryId]?.length ?? 0;
  }

  
  static bool hasSubCategories(String categoryId) {
    return subCategoryData.containsKey(categoryId) && 
           subCategoryData[categoryId]!.isNotEmpty;
  }


  static String getSubCategoryTitle(String categoryId, int index) {
    final subCategories = subCategoryData[categoryId];
    if (subCategories == null || index >= subCategories.length) {
      return '';
    }
    return subCategories[index]['title'] as String;
  }

  static IconData getSubCategoryIcon(String categoryId, int index) {
    final subCategories = subCategoryData[categoryId];
    if (subCategories == null || index >= subCategories.length) {
      return Icons.error;
    }
    return subCategories[index]['icon'] as IconData;
  }

 
  static List<String> getAllCategoryIds() {
    return subCategoryData.keys.toList();
  }

  
  static bool categoryExists(String categoryId) {
    return subCategoryData.containsKey(categoryId);
  }

  static List<Map<String, dynamic>> searchSubCategories(String query) {
    final results = <Map<String, dynamic>>[];
    final lowercaseQuery = query.toLowerCase();
    
    for (final category in subCategoryData.values) {
      for (final subCategory in category) {
        final title = subCategory['title'] as String;
        if (title.toLowerCase().contains(lowercaseQuery)) {
          results.add(subCategory);
        }
      }
    }
    
    return results;
  }
}
