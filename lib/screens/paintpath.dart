import 'package:flutter/material.dart';
import 'dart:math';

class Painter extends CustomPainter {
  Painter(
      {required this.data, required this.currentIndex, required this.sample});
  List<Offset> data;
  int currentIndex;
  int sample;
  final _random = Random();
  @override
  void paint(Canvas canvas, size) {
    var paint = Paint();
    paint.color = Colors.amber;
    paint.strokeWidth = 5;
    var lPaint = Paint();
    lPaint.color = Colors.red;
    lPaint.strokeWidth = 2;

    for (int i = 0; i < data.length; i += sample) {
      if (i < data.length - sample) {
        // paint.color = Color.fromRGBO(_random.nextInt(256), _random.nextInt(256),
        //     _random.nextInt(256), _random.nextDouble());
        canvas.drawLine(
          data[i],
          data[i + sample],
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
    //canvas.drawRect(boundingBox(data), lPaint);
    var a = boundingBox(data);

    //canvas..drawRect(a, lPaint);

    canvas.drawLine(a.topLeft, a.topRight, lPaint);
    canvas.drawLine(a.topRight, a.bottomRight, lPaint);
    canvas.drawLine(a.topLeft, a.bottomLeft, lPaint);
    canvas.drawLine(a.bottomLeft, a.bottomRight, lPaint);

    // canvas.drawCircle(centroid(data), 5, lPaint);

    paint.color = Colors.blue;
    paint.strokeWidth = 6;
    // canvas.drawCircle(data[currentIndex], 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Rect boundingBox(List<Offset> list) {
    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;
    for (int i = 0; i < list.length; i++) {
      minX = min(minX, list[i].dx);
      minY = min(minY, list[i].dy);
      maxX = max(maxX, list[i].dx);
      maxY = max(maxY, list[i].dy);
    }

    var space = 5;
    var rec = Rect.fromLTWH(minX, minY, (maxX - minX), (maxY - minY));

    //print(rec);
    return rec;
  }

  double indicativeAngle(List<Offset> points) {
    Offset c = centroid(points);
    return atan2(c.dy - points[0].dy, c.dx - points[0].dx);
  }

  Offset centroid(List<Offset> points) {
    double x = 0;
    double y = 0;
    for (int i = 0; i < points.length; i++) {
      x += points[i].dx;
      y += points[i].dy;
    }
    x = x / points.length;
    y = y / points.length;

    return Offset(x, y);
  }
}
