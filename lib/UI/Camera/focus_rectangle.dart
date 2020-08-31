import 'package:flutter/material.dart';

/// Widget to be on top of cameera to clarify user the correct area to place the code
/// color - The color of the area
class FocusRectangle extends StatelessWidget {
  final Color color;
  const FocusRectangle({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: RectangleModePhoto(),
      ),
    );
  }
}

///Creates a black semi-opaque rectangle on top of the camera
///Also creates a hole in the rectagle to simulate a focus area
///where the scanned code should be to promote better efficiency
class RectangleModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();
    reactPath.moveTo(size.width / 4, size.height / 6);
    reactPath.lineTo(size.width / 4, size.height * 5 / 6);
    reactPath.lineTo(size.width * 3 / 4, size.height * 5 / 6);
    reactPath.lineTo(size.width * 3 / 4, size.height / 6);
    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
