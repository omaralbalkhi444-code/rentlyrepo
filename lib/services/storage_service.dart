import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadUserImage(
      String uid, File file, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("user_uploads")
        .child(uid)
        .child(fileName);

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  static Future<String> uploadItemImage(
      String ownerId, File file, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("item_uploads")
        .child(ownerId)
        .child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
