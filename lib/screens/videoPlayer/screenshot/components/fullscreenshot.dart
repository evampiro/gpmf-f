import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gpmf/screens/Components/DialogPrompt.dart';
import 'package:gpmf/screens/Components/pixelcolor/colorpicker.dart';
import 'package:gpmf/screens/videoPlayer/models/outletholder.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/imageClipper.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/outletform.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';
import 'package:gpmf/utilities/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:random_color/random_color.dart';

import 'dart:ui' as ui;

class FullScreenShot extends ConsumerStatefulWidget {
  const FullScreenShot(
      {Key? key,
      required this.imageData,
      required this.outlet,
      required this.duration,
      this.currentOutlet})
      : super(key: key);

  final Uint8List imageData;
  final List<Outlets> outlet;
  final int duration;
  final Outlets? currentOutlet;
  @override
  ConsumerState<FullScreenShot> createState() => _FullScreenShotState();
}

class _FullScreenShotState extends ConsumerState<FullScreenShot>
    with TickerProviderStateMixin {
  final List<CustomMarker> markers = [];
  late AnimationController controller;
  bool confirm = false, isScreenshotMode = false, zoomed = false;
  Uint8List? modifiedImage;
  final GlobalKey _repaintKey = GlobalKey();
  int currentRender = 0;
  double angle = 0;
  Offset blur = const Offset(5, 5);
  var image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    IntentFunctions().isSpaceActive = false;
    if (widget.currentOutlet != null) {
      for (SingleOutlet value in widget.currentOutlet?.outlets ?? []) {
        markers.add(value.detail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        IntentFunctions().focus.requestFocus();
        IntentFunctions().isSpaceActive = true;
        if (markers.isEmpty) {
          return Future.value(true);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: FocusableActionDetector(
          autofocus: true,
          shortcuts: {escKeySet: EscKeyIntent()},
          actions: {
            EscKeyIntent: CallbackAction(onInvoke: (intent) {
              Navigator.pop(context);
            })
          },
          child: Stack(
            children: [
              GestureDetector(
                onTapUp: (details) async {
                  if (!zoomed) {
                    ColorPicker _colorPicker =
                        ColorPicker(bytes: widget.imageData);
                    var _color = await _colorPicker.getColor(
                      pixelPosition: details.localPosition,
                    );
                    if (_color.computeLuminance() > 0.5) {
                      _color = RandomColor().randomColor(
                          colorSaturation: ColorSaturation.highSaturation,
                          colorBrightness: ColorBrightness.dark);
                    } else {
                      _color = RandomColor().randomColor(
                          colorSaturation: ColorSaturation.highSaturation,
                          colorBrightness: ColorBrightness.light);
                    }
                    bool proceed = true;

                    // Rect test = Rect.fromLTWH(
                    //     details.localPosition.dx, details.localPosition.dy, 50, 50);
                    if (markers.isNotEmpty) {
                      for (int i = 0; i < markers.length; i++) {
                        var dist = (details.localPosition - markers[i].position)
                            .distance;
                        // print(dist);
                        if (dist < 50) {
                          proceed = false;
                        }
                        markers[i].selected = false;
                      }
                    }

                    if (proceed) {
                      setState(() {
                        markers.add(CustomMarker(
                            id: markers.isEmpty ? 0 : markers.length - 1,
                            selected: true,
                            position: Offset(
                              details.localPosition.dx + 1,
                              details.localPosition.dy + 5,
                            ),
                            color: _color));
                        confirm = checkMarkers(markers);
                      });
                    }
                  }
                },
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: InteractiveViewer(
                    onInteractionStart: (details) {},
                    onInteractionUpdate: (details) {
                      // print(details.scale);
                      if (details.scale > 1) {
                        setState(() {
                          zoomed = true;
                        });
                      } else {
                        setState(() {
                          zoomed = false;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        AnimatedRotation(
                            turns: angle / 360,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: MemoryImage(widget.imageData)),
                                ),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                    sigmaX: isScreenshotMode ? 0 : blur.dx,
                                    sigmaY: isScreenshotMode ? 0 : blur.dy,
                                  ),
                                  child: Container(),
                                ))),
                        Visibility(
                          visible: !isScreenshotMode,
                          child: Stack(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.transparent,
                                  child: ClipPath(
                                    clipper: ImageClipper(),
                                    child: AnimatedRotation(
                                      turns: angle / 360,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            image: DecorationImage(
                                                image: MemoryImage(
                                                    widget.imageData))),
                                      ),
                                    ),
                                  )),
                              Positioned(
                                left: 0,
                                // left: MediaQuery.of(context).size.width -
                                //     MediaQuery.of(context).size.width * .8,
                                top: MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).size.height * .8,
                                child: Container(
                                  // padding: EdgeInsets.all(50),
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * .65,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          color: Colors.transparent, width: 2)),
                                  child: Visibility(
                                    visible: true,
                                    child: GridPaper(
                                      interval: 100,
                                      subdivisions: 1,
                                      divisions: 1,
                                      color: Colors.grey,
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ),
                              //   AnimatedRotation(
                              //   //  angle: angle * 0.0174533,
                              //   turns: angle / 360,
                              //   duration: const Duration(milliseconds: 200),
                              //   child: image,
                              // ),
                            ],
                          ),
                        ),
                        for (int i = 0; i < markers.length; i++)
                          Positioned(
                            left: markers[i].position.dx - 25,
                            top: markers[i].position.dy - 50,
                            child: Visibility(
                              visible:
                                  !isScreenshotMode ? true : currentRender == i,
                              child: Listener(
                                onPointerDown: (details) {
                                  if (!zoomed) {
                                    if (details.kind ==
                                            PointerDeviceKind.mouse &&
                                        details.buttons ==
                                            kSecondaryMouseButton) {
                                      // ignore: prefer_function_declarations_over_variables
                                      Function markertest = () {
                                        markers.removeAt(markers.indexWhere(
                                            (element) =>
                                                element == markers[i]));
                                        setState(() {
                                          confirm = checkMarkers(markers);
                                        });
                                      };
                                      if (markers[i].category != null &&
                                          markers[i].size != null) {
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return DialogPrompt(
                                                onYes: () {
                                                  markertest();
                                                },
                                              );
                                            });
                                      } else {
                                        markertest();
                                      }
                                    } else if (details.kind ==
                                            PointerDeviceKind.mouse &&
                                        details.buttons ==
                                            kPrimaryMouseButton) {
                                      for (int j = 0; j < markers.length; j++) {
                                        markers[j].selected = false;
                                      }

                                      setState(() {
                                        markers[i].selected = true;
                                      });
                                    }
                                  }
                                },
                                child: Draggable(
                                  rootOverlay: true,
                                  onDragEnd: (drag) {
                                    if (!zoomed) {
                                      if (drag.offset.dx > 0 &&
                                          drag.offset.dy <
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) {
                                        setState(() {
                                          markers[i].position = Offset(
                                              drag.offset.dx + 25,
                                              drag.offset.dy + 50);
                                        });
                                      }
                                    }
                                  },
                                  feedback: Icon(
                                    Icons.room,
                                    color: markers[i].color.withOpacity(0.7),
                                    size: 50,
                                  ),
                                  childWhenDragging: Container(),
                                  child:
                                      Stack(clipBehavior: Clip.none, children: [
                                    // Positioned(
                                    //   left: 50,
                                    //   child: Visibility(
                                    //     visible: markers[i].selected,
                                    //     // markers[i].selected ? 1 : 0,
                                    //     // duration: const Duration(milliseconds: 100),
                                    //     child: GestureDetector(
                                    //       onTap: () {},
                                    //       child: Container(
                                    //         width: 200,
                                    //         height: 200,
                                    //         decoration: BoxDecoration(
                                    //             color: Colors.green,
                                    //             border: Border.all(
                                    //                 width: 2, color: markers[i].color)),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // InkWell(
                                    //   onTap: () {
                                    //     showDialog(
                                    //         context: context,
                                    //         builder: (_) {
                                    //           return Material(child: TextField());
                                    //         });
                                    //   },
                                    //   child: Icon(
                                    //     (markers[i].name == null &&
                                    //             markers[i].category == null)
                                    //         ? Icons.edit_location_alt
                                    //         : Icons.room,
                                    //     color: markers[i].color,
                                    //     size: 50,
                                    //   ),
                                    // ),
                                    PopupMenuButton(
                                      onCanceled: () {
                                        IntentFunctions().focus.requestFocus();
                                        setState(() {
                                          confirm = checkMarkers(markers);
                                        });
                                      },
                                      offset: Offset(50, 50),
                                      color: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                      itemBuilder: (_) {
                                        return [
                                          PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              height: 0,
                                              enabled: false,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                  color: markers[i].color,
                                                  width: 2,
                                                )),
                                                width: 300,
                                                height: 350,
                                                child: OutletForm(
                                                    customMarker: markers[i]),
                                                // child: ElevatedButton(
                                                //   onPressed: () {
                                                //     Navigator.pop(context);
                                                //   },
                                                //   child: const Text("test"),
                                                // ),
                                              ))
                                        ];
                                      },
                                      tooltip: generateToolTip(markers[i]),
                                      child: Icon(
                                        (markers[i].name == null &&
                                                markers[i].category == null &&
                                                markers[i].size == null)
                                            ? Icons.edit_location_alt
                                            : Icons.room,
                                        color: markers[i].color,
                                        size: 50,
                                      ),
                                    ),

                                    // Positioned(right: -15, top: -15, child: CloseButton())
                                  ]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (modifiedImage != null)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Draggable(
                    childWhenDragging: Container(),
                    feedback: Container(
                      height: 500,
                      width: 800,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: MemoryImage(modifiedImage!))),
                    ),
                    child: Container(
                      height: 500,
                      width: 800,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: MemoryImage(modifiedImage!))),
                    ),
                  ),
                ),
              Positioned(
                  left: (MediaQuery.of(context).size.width / 2) - 80,
                  bottom: 80,
                  child: SizedBox(
                    width: 250,
                    height: kBottomNavigationBarHeight,
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                angle = 0;
                              });
                            },
                            child: Slider(
                              label: angle.toString(),
                              value: angle,
                              onChanged: (value) {
                                setState(() {
                                  print(angle.toString());
                                  angle = value;
                                });
                              },
                              min: -60,
                              max: 60,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              onPressed: confirm
                                  ? () async {
                                      // widget.outlet.outlets.add(SingleOutlet(currentDuration: , imageData: widget.imageData, detail: detail));
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                          barrierDismissible: false);
                                      isScreenshotMode = true;
                                      Outlets outlet = Outlets(
                                          mainImageData: widget.imageData,
                                          outlets: [],
                                          currentDuration: widget.duration);
                                      setState(() {
                                        currentRender = -1;
                                      });
                                      await Future.delayed(
                                          Duration(milliseconds: 50), () async {
                                        RenderRepaintBoundary boundary =
                                            _repaintKey
                                                    .currentContext!
                                                    .findRenderObject()!
                                                as RenderRepaintBoundary;
                                        ui.Image image = await boundary.toImage(
                                            pixelRatio: MediaQuery.of(context)
                                                .devicePixelRatio);
                                        ByteData? byteData =
                                            await image.toByteData(
                                                format: ui.ImageByteFormat.png);
                                        outlet.mainImageData =
                                            (byteData?.buffer.asUint8List())!;
                                      });

                                      for (int i = 0; i < markers.length; i++) {
                                        setState(() {
                                          currentRender = i;
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 50),
                                            () async {
                                          RenderRepaintBoundary boundary =
                                              _repaintKey.currentContext!
                                                      .findRenderObject()!
                                                  as RenderRepaintBoundary;
                                          ui.Image image =
                                              await boundary.toImage(
                                                  pixelRatio:
                                                      MediaQuery.of(context)
                                                          .devicePixelRatio);
                                          ByteData? byteData =
                                              await image.toByteData(
                                                  format:
                                                      ui.ImageByteFormat.png);
                                          outlet.outlets.add(SingleOutlet(
                                              imageData: (byteData?.buffer
                                                  .asUint8List())!,
                                              detail: markers[i]));
                                        });
                                      }
                                      Navigator.pop(context);
                                      widget.outlet.add(outlet);
                                      isScreenshotMode = false;
                                      currentRender = 0;
                                      Navigator.pop(context);
                                      Future.delayed(Duration(milliseconds: 10),
                                          () {
                                        IntentFunctions().isSpaceActive = true;
                                        IntentFunctions().focus.requestFocus();
                                      });
                                      // setState(() {
                                      //   modifiedImage =
                                      //       byteData?.buffer.asUint8List();
                                      // });
                                    }
                                  : null,
                              child: const FittedBox(
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(fontSize: 20),
                                ),
                              )),
                        ),
                      ],
                    ),
                  )),
              const Positioned(
                right: 12,
                top: 12,
                child: CloseButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateToolTip(CustomMarker marker) {
    if (marker.name == null && marker.category == null) return '';
    return "\nName:  ${marker.name} \nCategory:  ${marker.category}\nSize:  ${marker.size}\n";
  }

  bool checkMarkers(List<CustomMarker> markers) {
    bool confirm = true;
    if (markers.isNotEmpty) {
      for (int i = 0; i < markers.length; i++) {
        if (markers[i].name == null && markers[i].category == null) {
          confirm = false;
          break;
        }
      }
    } else {
      confirm = false;
    }

    return confirm;
  }
}
