// CustomPaint(
//   size: Size(constraint.maxWidth, constraint.maxHeight),
//   painter: Painter(
//       currentIndex: index,
//       data: geoFiles,
//       sample: geoFiles[selectedFileIndex].sample,
//       transformer: transformer,
//       selectedIndex: selectedFileIndex),
// )
// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  Painter({
    required this.data,
  });
  List<Offset> data;
  @override
  void paint(Canvas canvas, size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 5;
    Path path = Path();
    data.forEach((element) {
      path.addPath(path, element);
    });
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
