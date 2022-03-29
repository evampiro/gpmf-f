import 'package:flutter/material.dart';

class TimeRuler extends StatelessWidget {
  const TimeRuler({Key? key, required this.duration}) : super(key: key);
  final int duration;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return CustomPaint(
        size: Size(constraint.maxWidth, constraint.maxHeight),
        painter: TimeRulerPainter(duration: duration),
        child: Container(),
      );
    });
  }
}

class TimeRulerPainter extends CustomPainter {
  TimeRulerPainter({required this.duration});
  final int duration;

  int subDivisor = 9, startPoint = 8;
  double labelSeparator = 18;
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    size = Size(size.width, size.height / 2.5);
    var paint = Paint()..color = Colors.white;
    var divisor = duration / 1000;

    if (divisor > 60) divisor = (divisor / 60).ceilToDouble();
    var widthDivisor = size.width / divisor;
    for (int i = 0; i < divisor; i++) {
      for (int j = 0; j < subDivisor; j++) {
        if (j != 0) {
          paint.color = Colors.white54;
          canvas.drawLine(
              Offset(
                  (i * widthDivisor) +
                      (j * (widthDivisor / subDivisor)) +
                      startPoint,
                  labelSeparator),
              Offset(
                  (i * widthDivisor) +
                      (j * (widthDivisor / subDivisor) + startPoint),
                  labelSeparator + (size.height / 12)),
              paint);
        }
      }
      paint.color = Colors.white;
      TextSpan span = TextSpan(
          style: TextStyle(color: Colors.white54, fontSize: 11), text: '${i}m');
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, new Offset(i * widthDivisor - 8 + startPoint, 0));
      canvas.drawLine(
          Offset(i * widthDivisor + startPoint, labelSeparator),
          Offset(i * widthDivisor + startPoint,
              labelSeparator + (size.height / 5)),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
