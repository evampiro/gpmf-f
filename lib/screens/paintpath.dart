import 'package:flutter/material.dart';
import 'dart:math';

class Painter extends CustomPainter {
  Painter({
    required this.data,
  });
  List<Offset> data;

  final _random = Random();
  @override
  void paint(Canvas canvas, size) {
    var paint = Paint();
    paint.color = Colors.amber;
    paint.strokeWidth = 5;

    for (int i = 0; i < data.length; i++) {
      if (i < data.length - 1) {
        // paint.color = Color.fromRGBO(_random.nextInt(256), _random.nextInt(256),
        //     _random.nextInt(256), _random.nextDouble());
        canvas.drawLine(
          data[i],
          data[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
