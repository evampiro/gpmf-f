import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/Component/pixelcolor/colorpicker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:random_color/random_color.dart';

class CustomMarker {
  CustomMarker({required this.position, required this.color});
  Offset position;
  Color color;
  LatLng? gps;
  String? name, category;
}

class FullScreenShot extends ConsumerStatefulWidget {
  FullScreenShot({Key? key, required this.imageData}) : super(key: key);

  final Uint8List imageData;

  @override
  ConsumerState<FullScreenShot> createState() => _FullScreenShotState();
}

class _FullScreenShotState extends ConsumerState<FullScreenShot> {
  final List<CustomMarker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
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

          setState(() {
            markers.add(
                CustomMarker(position: details.localPosition, color: _color));
          });
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
                    image:
                        DecorationImage(image: MemoryImage(widget.imageData))),
              ),
              for (int i = 0; i < markers.length; i++)
                Positioned(
                  left: markers[i].position.dx - 25,
                  top: markers[i].position.dy - 50,
                  child: Draggable(
                    rootOverlay: true,
                    onDragEnd: (drag) {
                      if (drag.offset.dx > 0 &&
                          drag.offset.dy < MediaQuery.of(context).size.height) {
                        setState(() {
                          markers[i].position =
                              Offset(drag.offset.dx + 25, drag.offset.dy + 50);
                        });
                      }
                    },
                    feedback: Icon(
                      Icons.room,
                      color: markers[i].color.withOpacity(0.8),
                      size: 50,
                    ),
                    childWhenDragging: Container(),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Icon(
                        Icons.room,
                        color: markers[i].color,
                        size: 50,
                      ),
                      // Positioned(right: -15, top: -15, child: CloseButton())
                    ]),
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
    );
  }
}
