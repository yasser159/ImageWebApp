import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class UploadImage {
  late Uint8List memoryImage;
  late String url;
  bool savingStarted = false;
  bool savingEnded = false;
  bool isSaved = false;
  bool isCancelled = false;
  final _progressController = BehaviorSubject<double?>();
  UploadTask? uploadTask;

  StreamSink<double?> get progressSink => _progressController.sink;

  Stream<double?> get progressStream => _progressController.stream;

  void dispose() {
    _progressController.close();
  }
}
