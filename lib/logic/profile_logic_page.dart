
import 'dart:io';

class ProfileLogic {
  File? profileImage;
  String fullName;
  String email;
  String phone;
  String location;
  String bank;

  ProfileLogic({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.bank,
    this.profileImage,
  });

  bool hasImage() {
    return profileImage != null;
  }

  bool validateForm(String? name, String? email, String? phone) {
    return (name?.isNotEmpty == true) &&
        (email?.isNotEmpty == true) &&
        (phone?.isNotEmpty == true);
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    File? image,
  }) {
    if (name != null) fullName = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (image != null) profileImage = image;
  }

  Map<String, dynamic> getProfileData() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'bank': bank,
      'hasImage': hasImage(),
    };
  }

  String getUpdateSuccessMessage() {
    return "Profile Updated Successfully!";
  }

  String getUpdateErrorMessage() {
    return "Failed to update profile";
  }

  bool isProfileChanged({
    String? name,
    String? email,
    String? phone,
    File? image,
  }) {
    return name != fullName ||
        email != this.email ||
        phone != this.phone ||
        image != profileImage;
  }
}
