import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/components/timeruler.dart';
import 'package:gpmf/utilities/exporter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLine extends ConsumerStatefulWidget {
  const TimeLine(
      {Key? key,
      required this.duration,
      required this.leftplayer,
      required this.rightplayer})
      : super(key: key);

  final int duration;
  final Player leftplayer, rightplayer;

  @override
  ConsumerState<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends ConsumerState<TimeLine> {
  double currentPosition = 0;
  bool isAnimated = true;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      //print(constraint);
      widget.leftplayer.positionStream.listen((event) {
        currentPosition = mapDouble(
            x: event.position!.inSeconds.toDouble(),
            in_min: 0,
            in_max: widget.duration.toDouble() / 1000,
            out_min: 0,
            out_max: constraint.maxWidth);
        // currentPosition -= 8.5;
        if (!mounted) return;
        setState(() {});
      });
      return GestureDetector(
        onTapUp: (detail) {
          //print("here");
          calculatePosition(detail.localPosition.dx, constraint.maxWidth);
        },
        child: Stack(
          children: [
            Container(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              color: Colors.transparent,
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.transparent,
              ),
            ),
            TimeRuler(
              duration: widget.duration,
            ),
            AnimatedPositioned(
              left: currentPosition.toDouble(),
              top: 0,
              duration: Duration(milliseconds: isAnimated ? 1000 : 0),
              child: Draggable(
                onDragEnd: (detail) {
                  calculatePosition(detail.offset.dx, constraint.maxWidth);
                },
                axis: Axis.horizontal,
                feedback: Container(
                  height: constraint.maxHeight,
                  width: 2,
                  color: Colors.blue[800],
                ),
                child: Container(
                  height: constraint.maxHeight,
                  width: 2,
                  color: Colors.blue,
                ),
                childWhenDragging: Container(),
              ),
            )
          ],
        ),
      );
    });
  }

  void calculatePosition(double dx, double width) {
    if (dx > 0) {
      setState(() {
        isAnimated = false;
        currentPosition = dx;
        widget.leftplayer.seek(Duration(
            milliseconds: map(currentPosition.toInt(), 0, width.toInt(), 0,
                widget.duration)));
        widget.rightplayer.seek(Duration(
            milliseconds: map(currentPosition.toInt(), 0, width.toInt(), 0,
                widget.duration)));
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          isAnimated = true;
        });
      });
    }
  }
}

class TimelineHeadClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var controlPoint = Offset(size.width / 2, size.height / 2);
    var endPoint = Offset(size.width, size.height);

    Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
