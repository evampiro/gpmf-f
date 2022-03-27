import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/components/timeruler.dart';
import 'package:gpmf/utilities/exporter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rulers/rulers.dart';

class TimeLine extends ConsumerStatefulWidget {
  const TimeLine({Key? key, required this.duration, required this.player})
      : super(key: key);

  final int duration;
  final Player player;

  @override
  ConsumerState<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends ConsumerState<TimeLine> {
  double currentPosition = 0;
  bool isAnimated = true;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      widget.player.positionStream.listen((event) {
        currentPosition = mapDouble(
            x: event.position!.inMilliseconds.toDouble(),
            in_min: 0,
            in_max: widget.duration.toDouble(),
            out_min: 0,
            out_max: constraint.maxWidth);
        setState(() {});
      });
      return Container(
        child: GestureDetector(
          onTapUp: (detail) {
            print("here");
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
                duration: Duration(milliseconds: isAnimated ? 200 : 0),
                child: Draggable(
                  onDragEnd: (detail) {
                    calculatePosition(detail.offset.dx, constraint.maxWidth);
                  },
                  axis: Axis.horizontal,
                  feedback: Container(
                    height: constraint.maxHeight,
                    width: 2,
                    color: Colors.blue[700],
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
        ),
      );
    });
  }

  void calculatePosition(double dx, double width) {
    if (dx > 0) {
      setState(() {
        isAnimated = false;
        currentPosition = dx;
        widget.player.seek(Duration(
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
