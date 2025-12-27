
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PersonalInfoLogic {
  final ImagePicker picker = ImagePicker();
  
  Future<Map<String, String>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'password': prefs.getString('password') ?? '',
      'phone': prefs.getString('phone') ?? '',
    };
  }
  
  
  Future<void> saveUserData({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('phone', phone);
  }
  
  
  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
