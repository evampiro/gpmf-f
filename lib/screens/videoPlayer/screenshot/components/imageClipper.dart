import 'package:flutter/cupertino.dart';

class ImageClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();

    path
      ..moveTo(0, size.height - size.height * .8)
      ..lineTo(size.width, size.height - size.height * .8)
      ..lineTo(
          size.width, ((size.height - size.height * .8) + size.height * .65))
      ..lineTo(0, ((size.height - size.height * .8) + size.height * .65))
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    //throw UnimplementedError();
    return false;
  }
}
