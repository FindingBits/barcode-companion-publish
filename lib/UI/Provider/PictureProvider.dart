import 'package:flutter/material.dart';

/// Allowing communication between a button and Camera to allow taking a picture
/// Example:
/// Button side
/// ```dart
/// Consumer<PictureProvider>(
///   builder: (context, _window, child) {
///     return GestureDetector(
///       onTap: () => _window.takePhoto(),
///     );
///   },
/// )
/// ```
/// Camera side
/// ```dart
/// Consumer<PictureProvider>(
///    builder: (context, _popupwindow, child) {
///      if (_popupwindow.takephoto) {
///        _popupwindow.closephoto(); // Later change this
///        funcToTakePhoto(); // Defined on the camera widget
///      };
///    },
///  )
/// ```
class PictureProvider with ChangeNotifier {
  bool _takephoto = false;
  bool _working = false;
  set working(bool val) {
    _working = val;
  }

  get working => _working;

  /// Send the trigger to take the photo
  /// Camera must be listening to picture provider
  void takePhoto() {
    _takephoto = true;
    notifyListeners();
    // Maybe add here _takephoto = false; and delete confusing closephoto
  }

  /// After taking the photo, call this function to reset the value to false
  void closephoto() {
    _takephoto = false;
  }

  get takephoto => _takephoto;
}
