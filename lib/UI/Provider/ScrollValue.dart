import 'package:flutter/foundation.dart';

/// Provider carrying the draggable pannel from the menu
/// This value is used for several calculations
/// Example:
///
/// Setting value
/// ```dart
/// Consumer<ScrollValue>(
///   builder: (context, _scroll, child) {
///     return GestureDetector(
///       onTap: () => _scroll = someValue,
///     );
///   },
/// )
/// ```
///
/// Acessing value
/// ```dart
/// Consumer<ScrollValue>(
///   builder: (context, _scroll, child) {
///     return Opacity(
///       opacity: _scroll.value
///       // Extra code
///     );
///   }
/// )
/// ```
class ScrollValue with ChangeNotifier {
  double _value = 1;

  set value(double val) {
    _value = val;
    notifyListeners();
  }

  double get value => _value;
}
