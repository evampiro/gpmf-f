import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/Component/pixelcolor/colorpicker.dart';
import 'package:gpmf/screens/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:random_color/random_color.dart';

class CustomMarker {
  CustomMarker(
      {required this.position,
      required this.color,
      this.selected = false,
      required this.id});
  Offset position;
  Color color;
  LatLng? gps;
  String? name, category;
  bool selected;
  int id;
}

class FullScreenShot extends ConsumerStatefulWidget {
  const FullScreenShot({Key? key, required this.imageData}) : super(key: key);

  final Uint8List imageData;

  @override
  ConsumerState<FullScreenShot> createState() => _FullScreenShotState();
}

class _FullScreenShotState extends ConsumerState<FullScreenShot>
    with TickerProviderStateMixin {
  final List<CustomMarker> markers = [];
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusableActionDetector(
        autofocus: true,
        shortcuts: {escKeySet: EscKeyIntent()},
        actions: {
          EscKeyIntent: CallbackAction(onInvoke: (intent) {
            Navigator.pop(context);
          })
        },
        child: GestureDetector(
          onTapUp: (details) async {
            ColorPicker _colorPicker = ColorPicker(bytes: widget.imageData);
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
                var dist =
                    (details.localPosition - markers[i].position).distance;
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
              });
            }
          },
          child: InteractiveViewer(
            child: Stack(
              children: [
                const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: MemoryImage(widget.imageData))),
                ),
                for (int i = 0; i < markers.length; i++)
                  Positioned(
                    left: markers[i].position.dx - 25,
                    top: markers[i].position.dy - 50,
                    child: Listener(
                      onPointerDown: (details) {
                        if (details.kind == PointerDeviceKind.mouse &&
                            details.buttons == kSecondaryMouseButton) {
                          setState(() {
                            markers.removeAt(markers.indexWhere(
                                (element) => element == markers[i]));
                          });
                        } else if (details.kind == PointerDeviceKind.mouse &&
                            details.buttons == kPrimaryMouseButton) {
                          for (int j = 0; j < markers.length; j++) {
                            markers[j].selected = false;
                          }

                          setState(() {
                            markers[i].selected = true;
                          });
                        }
                      },
                      child: Draggable(
                        rootOverlay: true,
                        onDragEnd: (drag) {
                          if (drag.offset.dx > 0 &&
                              drag.offset.dy <
                                  MediaQuery.of(context).size.height) {
                            setState(() {
                              markers[i].position = Offset(
                                  drag.offset.dx + 25, drag.offset.dy + 50);
                            });
                          }
                        },
                        feedback: Icon(
                          Icons.room,
                          color: markers[i].color.withOpacity(0.7),
                          size: 50,
                        ),
                        childWhenDragging: Container(),
                        child: Stack(clipBehavior: Clip.none, children: [
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
                          PopupMenuButton(
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
                                      height: 200,
                                      // child: ElevatedButton(
                                      //   onPressed: () {
                                      //     Navigator.pop(context);
                                      //   },
                                      //   child: const Text("test"),
                                      // ),
                                    ))
                              ];
                            },
                            tooltip: markers[i].position.toString(),
                            child: Icon(
                              Icons.room,
                              color: markers[i].color,
                              size: 50,
                            ),
                          ),

                          // Positioned(right: -15, top: -15, child: CloseButton())
                        ]),
                      ),
                    ),
                  ),
                const Positioned(
                  right: 12,
                  top: 12,
                  child: CloseButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
