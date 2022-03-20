// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/AIv2.dart';
import 'package:gpmf/screens/CustomPainByLatLng.dart';
import 'package:gpmf/screens/LocationsClass';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class MapScreenHolder extends StatefulWidget {
  const MapScreenHolder(
      {Key? key,
      required this.mapController,
      required this.coordinates,
      this.isLine = true})
      : super(key: key);
  final MapController? mapController;
  //final List<GeoFile>? geoFiles;
  final bool isLine;
  final List<LocationsData> coordinates;
  @override
  State<MapScreenHolder> createState() => _MapState();
}

class _MapState extends State<MapScreenHolder> {
  int index = 0, selectedFileIndex = 5;
  bool isAnimation = true, follow = false;
  int counter = 0;

  // void _gotoDefault() {
  //   widget.mapController?.center = LatLng(35.68, 51.41);
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    widget.mapController?.addListener(() {
      setState(() {});
    });
  }

  void _onDoubleTap() {
    isAnimation = false;
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      setState(() {
        isAnimation = true;
      });
    });
    print(isAnimation);
    widget.mapController?.zoom += 0.5;
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      isAnimation = false;
    });
    Future.delayed(const Duration(seconds: 3))
        .then((value) => setState(() => (isAnimation = true)));
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      widget.mapController?.zoom += 1;
      setState(() {});
    } else if (scaleDiff < 0) {
      widget.mapController?.zoom -= 1;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      widget.mapController?.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  // Widget _buildMarkerWidget(Offset pos, Color color) {
  //   return Positioned(
  //     left: pos.dx - 16,
  //     top: pos.dy - 16,
  //     width: 24,
  //     height: 24,
  //     child: Icon(Icons.location_on, color: color),
  //   );
  // }

  // Widget _buildDotWidget(Offset pos, Color color, {Offset? prev}) {
  //   if (prev != null) print('$pos $prev');
  //   return Positioned(
  //     left: pos.dx - 16,
  //     top: pos.dy - 16,
  //     width: 4,
  //     height: 4,
  //     child: Container(
  //       color: color,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Consumer(builder: (context, ref, s) {
        // print(
        //     '$index ${widget.markers![index].latitude} ${widget.markers![index].longitude}');

        return MapLayoutBuilder(
          controller: widget.mapController!,
          builder: (context, transformer) {
            // if (counter == 0 && isAnimation == false) {
            //   counter++;
            // }
            // if (counter == 1 && isAnimation == false) {
            //   counter = 0;
            //   isAnimation = true;
            // }
            // print(transformer.controller.projection);
            final markerPositions = widget.coordinates
                .map((e) =>
                    transformer.fromLatLngToXYCoords(LatLng(e.lat, e.lng)))
                .toList();
            // widget.markers?.map(transformer.fromLatLngToXYCoords).toList();

            // if (index > 0 && index < geoFiles[0].geoData.length - 1) {
            //   angle = math.atan(
            //       (markerPositions[index + 1].dy - markerPositions[index].dy) /
            //           ((markerPositions[index + 1].dx -
            //               markerPositions[index].dx)));
            // }
            final markerWidgets = [
              ClipRRect(
                child: Stack(children: [
                  CustomPaint(
                    size: Size(constraint.maxWidth, constraint.maxHeight),
                    painter: Custompaint(
                        mainData: widget.coordinates,
                        data: markerPositions,
                        isLine: widget.isLine),
                  )
                ]

                    // Transform.rotate(
                    //   angle: 0.58,
                    //   child: Container(
                    //     color: Colors.red,
                    //     width: 100,
                    //     height: 100,
                    //   ),
                    // )

                    ),
              )
            ];

            // final homeLocation =
            //     transformer.fromLatLngToXYCoords(LatLng(35.68, 51.412));

            // final homeMarkerWidget =
            //     _buildMarkerWidget(homeLocation, Colors.black);

            // final centerLocation = Offset(
            //     transformer.constraints.biggest.width / 2,
            //     transformer.constraints.biggest.height / 2);

            // final centerMarkerWidget =
            //     _buildMarkerWidget(centerLocation, Colors.purple);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _onDoubleTap,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onTapUp: (details) {
                setState(() {
                  isAnimation = true;
                });
                // final location =
                //     transformer.fromXYCoordsToLatLng(details.localPosition);

                // final clicked = transformer.fromLatLngToXYCoords(location);

                // var matchGreat = markerPositions
                //     .where((e) => e.dx >= clicked.dx && e.dy >= clicked.dy)
                //     .toList();
                // var matchLess = markerPositions
                //     .where((e) => e.dx <= clicked.dx && e.dy <= clicked.dy)
                //     .toList();
              },
              child: Listener(
                onPointerHover: (event) {
                  // final location =
                  //     transformer.fromXYCoordsToLatLng(event.localPosition);

                  // final clicked = transformer.fromLatLngToXYCoords(location);
                  // print(clicked);
                },
                behavior: HitTestBehavior.opaque,
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    setState(() {
                      isAnimation = false;
                    });
                    final delta = event.scrollDelta;

                    widget.mapController?.zoom -= delta.dy / 1000.0;
                    // ref.read(widget.geoFile.state).state = geoFiles;
                    //  ref.read(refreshProvider.state).state = sample;

                    Future.delayed(const Duration(milliseconds: 500))
                        .then((value) => setState(() => (isAnimation = true)));
                  }
                },
                child: Stack(
                  children: [
                    Map(
                      controller: widget.mapController!,
                      builder: (context, x, y, z) {
                        //Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.

                        //Google Maps
                        final url =
                            'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                        // final darkUrl =
                        //     'https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';
                        // //Mapbox Streets
                        // final url =
                        //     'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y?access_token=YOUR_MAPBOX_ACCESS_TOKEN';

                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    //  homeMarkerWidget,
                    ...markerWidgets,
                    if (selectedFileIndex > 0)
                      AnimatedPositioned(
                          duration: isAnimation
                              ? const Duration(milliseconds: 500)
                              : const Duration(microseconds: 0),
                          left: markerPositions[index].dx - 8,
                          top: markerPositions[index].dy - 8,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    boxShadow: const [
                                      BoxShadow(
                                          spreadRadius: 0.5, blurRadius: 5)
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 6,
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )

                                  // Opacity(
                                  //   opacity: 0,
                                  //   child: AnimatedRotation(
                                  //     turns: -math.pi / angle,
                                  //     duration: const Duration(milliseconds: 500),
                                  //     child: const Icon(
                                  //       Icons.arrow_back,
                                  //       size: 15,
                                  //     ),
                                  //   ),
                                  // ),
                                  ),
                              Positioned(
                                  top: -30,
                                  left: 15,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    height: 25,
                                    color: Colors.grey,
                                    child: FittedBox(
                                        child: Center(
                                            child: Text(index.toString()))),
                                  ))
                            ],
                          )),
                    // centerMarkerWidget,
                  ],
                ),
              ),
            );
          },
        );
      });
    });
  }

  int map(int x, int in_min, int in_max, int out_min, int out_max) {
    return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)
        .toInt();
  }

  double mapDouble(
      {required double x,
      required double in_min,
      required double in_max,
      required double out_min,
      required double out_max}) {
    var calc =
        ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
    if (calc > out_max) {
      return out_max;
    } else if (calc < out_min) {
      return out_min;
    } else {
      return calc;
    }
  }

  int calculateSample({required int max, required int min, required value}) {
    var calc = mapDouble(
        x: value,
        in_min: 17,
        in_max: 18,
        out_min: min.toDouble(),
        out_max: max.toDouble());

    return ((max - calc) + 1).toInt();
  }
}
