import 'package:flutter/material.dart';

class ICAppState extends ChangeNotifier {
  // App States
  bool isContentEdited = false;

  void setContentEditedState(bool isEdited) {
    isContentEdited = isEdited;
    // notifyListeners();
  }
}
