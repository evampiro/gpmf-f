import 'package:flutter/material.dart';
import 'dart:math';

class Painter extends CustomPainter {
  Painter({required this.data, required this.currentIndex});
  List<Offset> data;
  int currentIndex;
  final _random = Random();
  @override
  void paint(Canvas canvas, size) {
    var paint = Paint();
    paint.color = Colors.amber;
    paint.strokeWidth = 5;
    var lPaint = Paint();
    lPaint.color = Colors.red;
    lPaint.strokeWidth = 1;
    for (int i = 0; i < data.length; i++) {
      if (i < data.length - 1) {
        // paint.color = Color.fromRGBO(_random.nextInt(256), _random.nextInt(256),
        //     _random.nextInt(256), _random.nextDouble());
        canvas.drawLine(
          data[i],
          data[i + 1],
          paint,
        );
        // if (i % 12 == 0) {
        //   canvas.drawCircle(data[i], 1, lPaint);
        //   // canvas.drawLine(
        //   //     data[i], Offset(data[i].dx + 10, data[i].dy - 10), lPaint);
        //   // canvas.drawLine(
        //   //     data[i], Offset(data[i].dx - 10, data[i].dy - 10), lPaint);
        // }
      }
    }

    paint.color = Colors.blue;
    paint.strokeWidth = 6;
    // canvas.drawCircle(data[currentIndex], 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
