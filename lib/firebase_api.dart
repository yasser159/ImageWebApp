import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_web_app/upload_image.dart';

class FirebaseApi {
  static FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  static const String APP_MODE = 'Production';
  // static const String APP_MODE = 'Development';
  static const APP = 'ImageWebApp';

  static DocumentReference databaseReference =
      firestoreInstance.collection(APP_MODE).doc(APP);
  static Reference storageReference = FirebaseStorage.instance.ref();
  static Reference editedImagesStorageRef =
      storageReference.child('EditedImages');
  static CollectionReference firestoreReference =
      databaseReference.collection("Images");

  static Future<UploadImage> uploadEditedImage(
      UploadImage uploadImage, String imageName) async {
    try {
      DateTime dateTime = DateTime.now();
      uploadImage.savingStarted = true;
      // uploadImage.file =
      //     (await HighAltitudeImagePicker.downRes(uploadImage.file))!;
      if (uploadImage.isCancelled) {
        return uploadImage;
      }
      final UploadTask uploadTask = editedImagesStorageRef
          // .child('${dateTime.year}')
          // .child('${dateTime.month}')
          .child(imageName + dateTime.toIso8601String())
          .putData(uploadImage.memoryImage);
      uploadImage.uploadTask = uploadTask;
      final StreamSubscription<TaskSnapshot> streamSubscription =
          uploadTask.snapshotEvents.listen((event) {
        uploadImage.progressSink
            .add((event.bytesTransferred / event.totalBytes));
        print('EVENT ${event.state}');
      });
      final result = await uploadTask;
      streamSubscription.cancel();
      uploadImage.progressSink.add(null);
      streamSubscription.cancel();
      uploadImage.url = await result.ref.getDownloadURL();
      if (uploadImage.url.isNotEmpty) {
        uploadImage.isSaved = true;
      }
      uploadImage.savingEnded = true;
      addUploadedImageToFirestoreCollection(uploadImage.url);
      return uploadImage;
    } on PlatformException catch (err) {
      print(err);
      uploadImage.progressSink.add(null);
      uploadImage.savingEnded = true;
      uploadImage.isSaved = false;
      return uploadImage;
    } catch (e) {
      print(e);

      uploadImage.progressSink.add(null);
      uploadImage.savingEnded = true;
      uploadImage.isSaved = false;
      return uploadImage;
    }
  }

  static Future<void> addUploadedImageToFirestoreCollection(
      String imageUrl) async {
    try {
      await firestoreReference.doc().set({
        'imageUrl': imageUrl,
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<List<String>> fetchUploadedImages() async {
    try {
      List<String> images = [];
      var snapshots = await firestoreReference.get();
      for (var element in snapshots.docs) {
        var url = element.get('imageUrl');
        if (url is String) {
          images.add(url);
        } else {}
      }
      return images;
      // querySnapshot.docs;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
