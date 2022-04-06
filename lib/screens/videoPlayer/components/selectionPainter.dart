import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectionPainter extends CustomPainter {
  SelectionPainter(
      {required this.start, required this.end, required this.draw});
  Offset start, end;
  bool draw;
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    Paint paint = Paint();

    paint.style = PaintingStyle.stroke;

    Rect rect = Rect.fromPoints(
        Offset(start.dx + 0, start.dy - 40), Offset(end.dx + 0, end.dy - 40));
    if (draw) {
      paint..color = Colors.blue;
      canvas.drawRect(rect, paint);
      paint.style = PaintingStyle.fill;
      paint.color = Colors.blue.withOpacity(0.2);
      canvas.drawRect(
          Rect.fromPoints(Offset(start.dx + 0, start.dy - 40),
              Offset(end.dx + 0, end.dy - 40)),
          paint);
    } else {}
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
