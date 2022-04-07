import 'dart:ui';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/Components/DialogPrompt.dart';
import 'package:gpmf/screens/videoPlayer/components/selectionPainter.dart';
import 'package:gpmf/screens/videoPlayer/components/timeruler.dart';
import 'package:gpmf/screens/videoPlayer/models/outletholder.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/fullscreenshot.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';
import 'package:gpmf/utilities/exporter.dart';
import 'package:gpmf/utilities/intents.dart';
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
  bool isAnimated = true, isHovering = false, selectMode = false;
  int currentHover = 0;
  int currentHoverSelected = 0;
  List<int> selected = [0];
  Offset selectStart = Offset.zero, selectEnd = Offset.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    IntentFunctions().onControlAKey = () async {
      if (widget.outlets.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: 20), () {
          widget.outlets.forEach((element) {
            selected.add(widget.outlets.indexOf(element));
          });
        });

        setState(() {});
      }
    };
  }

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

      // print((-MediaQuery.of(context).size.height / 1.8).toString() +
      //     ' ' +
      //     constraint.maxHeight.toString());
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
          Listener(
            onPointerDown: (details) {
              if (details.kind == PointerDeviceKind.mouse &&
                  details.buttons == kSecondaryMouseButton) {
                setState(() {
                  selected.clear();
                });
              }
            },
            child: GestureDetector(
              onTapUp: (detail) {
                setState(() {
                  selected.clear();
                });
                calculatePosition(detail.localPosition.dx, constraint.maxWidth);
              },
              onPanEnd: (details) {
                setState(() {
                  selectMode = false;
                });
              },
              onPanUpdate: (details) {
                Rect selection = Rect.fromPoints(
                    Offset(selectStart.dx, selectStart.dy - 40),
                    Offset(details.localPosition.dx,
                        details.localPosition.dy - 40));

                widget.outlets.forEach(
                  (element) {
                    Rect current = Rect.fromLTWH(element.currentPosition.dx,
                        element.currentPosition.dy, 30, 30);
                    int index = widget.outlets.indexWhere((e) => e == element);
                    if (selection.overlaps(current)) {
                      if (!selected.contains(index)) selected.add(index);
                    } else {
                      if (selected.contains(index)) {
                        setState(() {
                          selected.remove(index);
                        });
                      }
                    }
                  },
                );
                setState(() {
                  selectEnd = details.localPosition;
                });
              },
              onPanStart: (details) {
                setState(() {
                  selectMode = true;
                  selectStart = Offset(
                      details.localPosition.dx, details.localPosition.dy);
                  selectEnd = Offset(
                      details.localPosition.dx, details.localPosition.dy);
                });
              },
              child: TimeRuler(
                duration: widget.duration,
              ),
            ),
          ),
          if (widget.outlets.isNotEmpty)
            Positioned(
              top: -(MediaQuery.of(context).size.height),
              left: -calclatePositionFromDuration(
                  widget.outlets[currentHover].currentDuration.toDouble(),
                  constraint.maxWidth),
              child: Visibility(
                visible: isHovering,
                child: AnimatedOpacity(
                  opacity: isHovering ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 5,
                        height: MediaQuery.of(context).size.height * 5,
                        color: Colors.black54.withOpacity(0.35)),
                  ),
                ),
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
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height),
                    for (int i = 0; i < widget.outlets.length; i++)
                      Builder(builder: (context) {
                        int size = 30;
                        Offset position = Offset(
                            calclatePositionFromDuration(
                                widget.outlets[i].currentDuration.toDouble(),
                                constraint.maxWidth),
                            calculateTopOffset(i, constraint.maxHeight, size));
                        widget.outlets[i].currentPosition = position;
                        return Positioned(
                          left: position.dx,
                          top: position.dy,
                          child: Builder(builder: (context) {
                            return AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: isHovering && currentHover == i ? 2 : 1,
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
                                    currentHoverSelected = 0;
                                  });
                                },
                                child: Listener(
                                  onPointerDown: (details) {
                                    if (details.kind ==
                                            PointerDeviceKind.mouse &&
                                        details.buttons ==
                                            kSecondaryMouseButton) {
                                      print(details.position);

                                      showMenu(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                              details.position.dx + 30,
                                              details.position.dy,
                                              MediaQuery.of(context).size.width,
                                              0),
                                          items: [
                                            PopupMenuItem(
                                                onTap: () async {
                                                  //  Navigator.pop(context);
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 50),
                                                      () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return DialogPrompt(
                                                              onYes: () {
                                                            setState(() {
                                                              widget.outlets
                                                                  .removeAt(i);
                                                            });
                                                          });
                                                        });
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: const Center(
                                                    child: Text("Delete")))
                                          ]);
                                    }
                                  },
                                  onPointerSignal: (details) async {
                                    if (details is PointerScrollEvent) {
                                      final delta = details.scrollDelta;
                                      if (delta.dy < 0) {
                                        if (currentHoverSelected <
                                            widget.outlets[currentHover].outlets
                                                    .length -
                                                1) {
                                          setState(() {
                                            currentHoverSelected++;
                                          });
                                        }
                                      } else {
                                        if (currentHoverSelected > 0) {
                                          setState(() {
                                            currentHoverSelected--;
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.leftplayer.pause();
                                      widget.leftplayer.seek(Duration(
                                          milliseconds: widget
                                              .outlets[i].currentDuration));
                                      setState(() {
                                        currentPosition =
                                            calclatePositionFromDuration(
                                                widget
                                                    .outlets[i].currentDuration
                                                    .toDouble(),
                                                constraint.maxWidth);
                                      });
                                      Future.delayed(
                                          const Duration(milliseconds: 1000),
                                          () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          widget.leftplayer.pause();
                                          return FullScreenShot(
                                              imageData: widget
                                                  .outlets[i].mainImageData,
                                              outlet: widget.outlets,
                                              duration: widget
                                                  .outlets[i].currentDuration,
                                              currentOutlet: widget.outlets[i]);
                                        }));
                                      });
                                    },
                                    child: Container(
                                      width: size.toDouble(),
                                      height: size.toDouble(),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 2,
                                              color: selected.contains(i)
                                                  ? Colors.blue
                                                  : Colors.transparent),
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
                                                  .outlets[i]
                                                  .outlets[0]
                                                  .imageData))),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                              right: -10,
                                              top: -10,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: Colors.blue,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    isHovering &&
                                                            currentHover == i
                                                        ? (currentHoverSelected +
                                                                1)
                                                            .toString()
                                                        : widget.outlets[i]
                                                            .outlets.length
                                                            .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    Visibility(
                      visible: selectMode,
                      child: CustomPaint(
                        painter: SelectionPainter(
                            draw: selectMode,
                            start: selectStart,
                            end: selectEnd),
                      ),
                    ),
                    if (widget.outlets.isNotEmpty)
                      Positioned(
                          // right: -constraint.maxWidth * .5,
                          // top: -(constraint.maxWidth * .5 * 0.5625) - 20,
                          left: MediaQuery.of(context).size.width / 4,
                          top: -(MediaQuery.of(context).size.height / 1.8),
                          child: Visibility(
                            visible: isHovering,
                            child: AnimatedOpacity(
                              opacity: isHovering ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Stack(
                                children: [
                                  // BackdropFilter(
                                  //   filter:
                                  //       ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  //   child: Container(),
                                  // ),
                                  Container(
                                    width: constraint.maxWidth * .5,
                                    height: constraint.maxWidth * .5 * 0.5625,
                                    decoration: widget.outlets[currentHover]
                                            .outlets.isNotEmpty
                                        ? BoxDecoration(
                                            // color: widget
                                            //     .outlets[currentHover]
                                            //     .outlets[currentHoverSelected]
                                            //     .detail
                                            //     .color,
                                            color: Colors.transparent,
                                            // boxShadow: const [
                                            //   BoxShadow(
                                            //       spreadRadius: 2,
                                            //       blurRadius: 10,
                                            //       color: Colors.black54)
                                            // ],

                                            image: DecorationImage(
                                                image: MemoryImage(widget
                                                    .outlets[currentHover]
                                                    .outlets[
                                                        currentHoverSelected]
                                                    .imageData)))
                                        : const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                            left: mapDouble(
                                                x: widget
                                                    .outlets[currentHover]
                                                    .outlets[
                                                        currentHoverSelected]
                                                    .detail
                                                    .position
                                                    .dx,
                                                in_min: 0,
                                                in_max: 1920,
                                                out_min: 0,
                                                out_max:
                                                    constraint.maxWidth * .5),
                                            top: mapDouble(
                                                x: widget
                                                    .outlets[currentHover]
                                                    .outlets[
                                                        currentHoverSelected]
                                                    .detail
                                                    .position
                                                    .dy,
                                                in_min: 0,
                                                in_max: 1080,
                                                out_min: 0,
                                                out_max: constraint.maxWidth *
                                                    .5 *
                                                    0.5625),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.black
                                                      .withOpacity(0.35)),
                                              child: Stack(
                                                children: [
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 5, sigmaY: 5),
                                                  ),
                                                  Text(generateToolTip(widget
                                                      .outlets[currentHover]
                                                      .outlets[
                                                          currentHoverSelected]
                                                      .detail))
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            bottom: 10,
                                            left: constraint.maxWidth / 3.9,
                                            child: Row(
                                              children: widget
                                                  .outlets[currentHover].outlets
                                                  .map((e) {
                                                int index = widget
                                                    .outlets[currentHover]
                                                    .outlets
                                                    .indexOf(e);
                                                return Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 2.0),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          currentHoverSelected ==
                                                                  index
                                                              ? Colors.blue
                                                              : Colors.grey),
                                                );
                                              }).toList(),
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
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

  bool checkRects(Rect original, Rect check) {
    if (original.left <= check.left &&
        original.top <= check.top &&
        (original.left + original.width) >= (check.left + check.width) &&
        (original.top + original.height) >= (check.top + check.height)) {
      return true;
    } else {
      return false;
    }
  }

  String generateToolTip(CustomMarker marker) {
    if (marker.name == null && marker.category == null) return '';
    return "Name:  ${marker.name!.isEmpty ? 'N/A' : '${marker.name}'} \nCategory:  ${marker.category}\nSize:  ${marker.size}";
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

  double calculateTopOffset(int i, double maxHeight, size) {
    if ((i * size) + size > maxHeight - size) {
      var top = ((((i * size) + size).toDouble() - (maxHeight - size)));

      if (top + size > (maxHeight - size)) {
        top = top - (maxHeight - size);
      }

      return top;
    } else {
      return (i * size).toDouble();
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
