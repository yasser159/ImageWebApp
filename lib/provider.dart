import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_web_app/firebase_api.dart';
import 'package:image_web_app/upload_image.dart';

class ImageWebProvider extends ChangeNotifier {
  List<String> _uploadedImages = [];
  bool _isLoading = false;
  Uint8List? _pickedImage;
  Uint8List? _editedFinalImage;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  void setPickedImage(Uint8List value) {
    _pickedImage = value;
    notifyListeners();
  }

  Uint8List? get pickedImage => _pickedImage;

  void setEditedFinalImage(Uint8List value) {
    _editedFinalImage = value;
    notifyListeners();
  }

  Uint8List? get editedFinalImage => _editedFinalImage;

  Future<void> saveImageToFirebase(
      Uint8List editedImage, String pickedImageName) async {
    UploadImage uploadImage = UploadImage()..memoryImage = editedImage;
    var uploadedImage =
        await FirebaseApi.uploadEditedImage(uploadImage, pickedImageName);
    _uploadedImages.add(uploadedImage.url);
    notifyListeners();
    setIsLoading(false);
  }

  Future<void> getImagesFromFirebase() async {
    setIsLoading(true);
    _uploadedImages = await FirebaseApi.fetchUploadedImages();
    notifyListeners();
    setIsLoading(false);
  }

  List<String> get uploadedImages => _uploadedImages;

  void setUploadedImagesListWithInitialList(List<String> initialData) {
    _uploadedImages = [...initialData];
    notifyListeners();
  }
}
