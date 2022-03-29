import 'dart:typed_data';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/components/timeruler.dart';
import 'package:gpmf/screens/videoPlayer/models/outletholder.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';
import 'package:gpmf/utilities/exporter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLine extends ConsumerStatefulWidget {
  const TimeLine(
      {Key? key,
      required this.duration,
      required this.leftplayer,
      required this.rightplayer,
      required this.outlets})
      : super(key: key);

  final int duration;
  final Player leftplayer, rightplayer;
  final Outlets outlets;

  @override
  ConsumerState<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends ConsumerState<TimeLine> {
  double currentPosition = 0;
  bool isAnimated = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      // print(constraint.maxWidth);
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
      return Stack(
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
          GestureDetector(
            onTapUp: (detail) {
              calculatePosition(detail.localPosition.dx, constraint.maxWidth);
            },
            child: TimeRuler(
              duration: widget.duration,
            ),
          ),
          Positioned(
            left: 0,
            top: mapDouble(
                x: constraint.maxHeight,
                in_min: 0,
                in_max: 300,
                out_min: 30,
                out_max: 50),
            child: Container(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              color: Colors.grey.withOpacity(0.8),
              child: Stack(
                  // scrollDirection: Axis.horizontal,
                  children: List.generate(
                      5,
                      (index) => Positioned(
                          left: index * 100,
                          top: index * 25,
                          child: Container(
                            width: 25,
                            height: 25,
                            color: Colors.red,
                          )))
                  // widget.outlets.outlets
                  //     .map((e) => Positioned(
                  //           left: 100,
                  //           top: 25,
                  //           child: Container(
                  //             width: 25,
                  //             height: 25,
                  //             color: Colors.red,
                  //           ),
                  //         ))
                  //     .toList(),
                  ),
            ),
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

  double calclatePositionFromDuration(double currentDuration, double width) {
    return mapDouble(
        x: currentDuration,
        in_min: 0,
        in_max: widget.duration.toDouble(),
        out_min: 0,
        out_max: width);
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
