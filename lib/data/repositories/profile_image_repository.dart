import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ProfileImageRepository {
  const ProfileImageRepository({this.storage});

  final FirebaseStorage? storage;

  bool get cloudConfigured => storage != null;

  Future<String?> uploadProfileImage({
    required String ownerId,
    required String localPath,
  }) async {
    final storageInstance = storage;
    if (storageInstance == null) return null;

    final image = File(localPath);
    final reference = storageInstance.ref().child(
      'users/$ownerId/profile/avatar.jpg',
    );
    final upload = await reference.putFile(
      image,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return upload.ref.getDownloadURL();
  }

  Future<String?> getProfileImageUrl(String ownerId) async {
    final storageInstance = storage;
    if (storageInstance == null) return null;

    try {
      return await storageInstance
          .ref()
          .child('users/$ownerId/profile/avatar.jpg')
          .getDownloadURL();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') return null;
      rethrow;
    }
  }
}
