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

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gpmf/screens/LocationsClass';

class Custompaint extends CustomPainter {
  Custompaint(
      {required this.data, required this.isLine, required this.mainData});
  List<Offset> data;
  List<LocationsData> mainData;
  bool isLine;
  @override
  void paint(Canvas canvas, size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 5;
    // Path path = Path();
    for (int i = 0; i < data.length; i += 1) {
      if (isLine) {
        paint.strokeWidth = 3;
        if (mainData[i].duplicate) {
          paint.color = Colors.red;
        } else {
          paint.color = Colors.blue;
        }
        if (i < data.length - 1) {
          canvas.drawLine(data[i], data[i + 1], paint);
        }
      } else {
        paint.color = Colors.red;
        paint.strokeWidth = 1;
        canvas.drawCircle(data[i], 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
