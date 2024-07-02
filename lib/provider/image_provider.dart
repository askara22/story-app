import 'package:flutter/material.dart';

class TakeImageProvider extends ChangeNotifier {
  String? imagePath;

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }
}
