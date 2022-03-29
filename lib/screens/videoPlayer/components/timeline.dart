import 'dart:typed_data';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/components/timeruler.dart';
import 'package:gpmf/screens/videoPlayer/models/outletholder.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/fullscreenshot.dart';
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
  final List<Outlets> outlets;

  @override
  ConsumerState<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends ConsumerState<TimeLine> {
  double currentPosition = 0;
  bool isAnimated = true, isHovering = false;
  int currentHover = 0;
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
        clipBehavior: Clip.none,
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
                out_min: 20,
                out_max: 45),
            child: Container(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              //color: Colors.grey.withOpacity(0.8),
              child: Stack(clipBehavior: Clip.none,
                  // scrollDirection: Axis.horizontal,
                  children:
                      //  List.generate(
                      //     5,
                      //     (index) => Positioned(
                      //         left: index * 100,
                      //         top: index * 25,
                      //         child: Container(
                      //           width: 25,
                      //           height: 25,
                      //           color: Colors.red,
                      //         )))
                      [
                    for (int i = 0; i < widget.outlets.length; i++)
                      Positioned(
                        left: calclatePositionFromDuration(
                            widget.outlets[i].currentDuration.toDouble(),
                            constraint.maxWidth),
                        top: i * 50,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onHover: (v) {
                            setState(() {
                              isHovering = true;
                              currentHover = i;
                            });
                          },
                          onExit: (v) {
                            setState(() {
                              isHovering = false;
                            });
                          },
                          child: GestureDetector(
                            onTap: () {
                              widget.leftplayer.pause();
                              widget.leftplayer.seek(Duration(
                                  milliseconds:
                                      widget.outlets[i].currentDuration));
                              setState(() {
                                currentPosition = calclatePositionFromDuration(
                                    widget.outlets[i].currentDuration
                                        .toDouble(),
                                    constraint.maxWidth);
                              });
                              Future.delayed(const Duration(milliseconds: 1000),
                                  () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  widget.leftplayer.pause();
                                  return FullScreenShot(
                                      imageData: widget
                                          .outlets[i].outlets[0].imageData,
                                      outlet: widget.outlets,
                                      duration:
                                          widget.outlets[i].currentDuration,
                                      singleOutlets: widget.outlets[i].outlets);
                                }));
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        blurRadius: 10,
                                        color: Colors.black54)
                                  ],
                                  color: Colors.red,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: MemoryImage(widget
                                          .outlets[i].outlets[0].imageData))),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                      right: -10,
                                      top: -10,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.blue,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            widget.outlets[i].outlets.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ),
                                      )),
                                  Positioned(
                                      right: -500,
                                      top: -(500 * 0.5625) - 20,
                                      child: AnimatedOpacity(
                                        opacity: currentHover == i && isHovering
                                            ? 1
                                            : 0,
                                        duration: Duration(milliseconds: 200),
                                        child: Container(
                                          width: 500,
                                          height: 500 * 0.5625,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: MemoryImage(widget
                                                      .outlets[i]
                                                      .outlets[0]
                                                      .imageData))),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                  ]),
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
