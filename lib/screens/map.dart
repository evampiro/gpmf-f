import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:gpmf/screens/home.dart';
import 'package:gpmf/screens/paintpath.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class CompareOffset {
  CompareOffset({required this.offset, required this.distance});
  Offset offset;
  double distance;
}

class SelectorCompare {
  SelectorCompare({required this.compareOffset, required this.file});
  CompareOffset compareOffset;
  GeoFile file;
}

class MapScreen extends StatefulWidget {
  MapScreen(
      {Key? key,
      this.mapController,
      required this.geoFile,
      required this.leftPlayerController,
      required this.rightPlayerController})
      : super(key: key);
  final MapController? mapController;
  //final List<GeoFile>? geoFiles;
  final Provider<Player> leftPlayerController, rightPlayerController;
  final StateProvider<List<GeoFile>> geoFile;
  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> with SingleTickerProviderStateMixin {
  int index = 0, selectedFileIndex = 0, previousIndex = 0;
  bool isAnimation = true, follow = false;
  int counter = 0, animationDouble = 1500;
  double angle = 186;
  late MapTransformer mainTransformer;
  late AnimationController _controller;

  void _gotoDefault() {
    widget.mapController?.center = LatLng(35.68, 51.41);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.mapController?.addListener(() {
      setState(() {});
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _onDoubleTap() {
    isAnimation = false;
    Future.delayed(Duration(milliseconds: 50)).then((_) {
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
    Future.delayed(Duration(milliseconds: 500))
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

  Widget _buildMarkerWidget(Offset pos, Color color) {
    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 16,
      width: 24,
      height: 24,
      child: Icon(Icons.location_on, color: color),
    );
  }

  Widget _buildDotWidget(Offset pos, Color color, {Offset? prev}) {
    if (prev != null) print('${pos} ${prev}');
    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 16,
      width: 4,
      height: 4,
      child: Container(
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Consumer(builder: (context, ref, s) {
        final player = ref.watch(widget.leftPlayerController);
        final geoFiles = ref.watch(widget.geoFile.state).state;
        // var sample = calculateSample(
        //     max: 128, min: 1, value: widget.mapController?.zoom);
        // geoFiles[0].sample = sample;

        player.positionStream.listen(
          (event) {
            var localIndex = map(
                event.position!.inMilliseconds,
                0,
                geoFiles[selectedFileIndex].duration,
                0,
                geoFiles[selectedFileIndex].geoData.length);
            // print(localIndex);
            setState(() {
              previousIndex = index;
              index = localIndex;
            });

            // player.takeSnapshot(file, 200, 200);
            // index = localIndex;
            if (follow) {
              widget.mapController?.center = LatLng(
                  geoFiles[selectedFileIndex].geoData[index].lat,
                  geoFiles[selectedFileIndex].geoData[index].lon);
            }

            // Offset previous = mainTransformer.fromLatLngToXYCoords(LatLng(
            //     geoFiles[selectedFileIndex].geoData[index - 1].lat,
            //     geoFiles[selectedFileIndex].geoData[index - 1].lon));
            // Offset current = mainTransformer.fromLatLngToXYCoords(LatLng(
            //     geoFiles[selectedFileIndex].geoData[index].lat,
            //     geoFiles[selectedFileIndex].geoData[index].lon));

            // widget.mapController?.drag(
            //     -(current.dx - previous.dx), -(current.dy - previous.dy));
            // print(
            //     '$index ${widget.markers![index].latitude} ${widget.markers![index].longitude}');
          },
        );
        return MapLayoutBuilder(
          controller: widget.mapController!,
          builder: (context, transformer) {
            mainTransformer = transformer;
            // if (counter == 0 && isAnimation == false) {
            //   counter++;
            // }
            // if (counter == 1 && isAnimation == false) {
            //   counter = 0;
            //   isAnimation = true;
            // }
            // print(transformer.controller.projection);
            final markerPositions = geoFiles[selectedFileIndex]
                .geoData
                .map((e) =>
                    transformer.fromLatLngToXYCoords(LatLng(e.lat, e.lon)))
                .toList();
            // widget.markers?.map(transformer.fromLatLngToXYCoords).toList();

            if (index > 0 && index < geoFiles[0].geoData.length) {
              // angle = math.atan(
              //     (markerPositions[index + 9].dy - markerPositions[index].dy) /
              //         ((markerPositions[index + 9].dx -
              //             markerPositions[index].dx)));
              angle = (57.2958 *
                  math.atan2(
                      (markerPositions[index + 1].dy -
                          markerPositions[index].dy),
                      ((markerPositions[index + 1].dx -
                          markerPositions[index].dx))));

              // angle = (angle - pangle);

            }

            final markerWidgets = [
              ClipRRect(
                child: Stack(children: [
                  CustomPaint(
                    size: Size(constraint.maxWidth, constraint.maxHeight),
                    painter: Painter(
                        currentIndex: index,
                        data: geoFiles,
                        sample: geoFiles[selectedFileIndex].sample,
                        transformer: transformer,
                        selectedIndex: selectedFileIndex),
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
                _controller.reset();
                setState(() {
                  isAnimation = true;
                });
                final location =
                    transformer.fromXYCoordsToLatLng(details.localPosition);

                List<GeoFile> selected = [];
                geoFiles.forEach(
                  (element) {
                    if (element.boundingBox!.contains(
                        Offset(location.latitude, location.longitude))) {
                      selected.add(element);
                    }
                  },
                );

                final clicked = transformer.fromLatLngToXYCoords(location);

                // var matchGreat = markerPositions
                //     .where((e) => e.dx >= clicked.dx && e.dy >= clicked.dy)
                //     .toList();
                // var matchLess = markerPositions
                //     .where((e) => e.dx <= clicked.dx && e.dy <= clicked.dy)
                //     .toList();

                List<SelectorCompare> selection = [];
                selected.forEach((element) {
                  final markerPositions = element.geoData
                      .map((e) => transformer
                          .fromLatLngToXYCoords(LatLng(e.lat, e.lon)))
                      .toList();
                  var indexList = markerPositions
                      .map((e) => CompareOffset(
                          offset: e, distance: (e - clicked).distance))
                      .toList();
                  indexList.sort((a, b) => a.distance.compareTo(b.distance));
                  selection.add(SelectorCompare(
                      compareOffset: indexList[0], file: element));
                });

                selection.sort(((a, b) => a.compareOffset.distance
                    .compareTo(b.compareOffset.distance)));
                setState(() {
                  selectedFileIndex = geoFiles
                      .indexWhere((element) => selection[0].file == element);
                });

                // print('${location.longitude}, ${location.latitude}');
                // print('${clicked.dx}, ${clicked.dy}');
                // print(
                //     '${details.localPosition.dx}, ${details.localPosition.dy}');
                // // print(
                // //     "${(clicked - matchGreat[0]).distance} ${(clicked - matchLess.last).distance}");
                // print("${indexList[0].offset} ${indexList[0].distance}");
                //-----------//
                if (selectedFileIndex == 0) {
                  var indexList = markerPositions
                      .map((e) => CompareOffset(
                          offset: e, distance: (e - clicked).distance))
                      .toList();
                  indexList.sort((a, b) => a.distance.compareTo(b.distance));
                  var i = markerPositions
                      .indexWhere((e) => indexList[0].offset == e);

                  setState(() {
                    previousIndex = index;
                    index = i;
                  });
                  var dist =
                      (markerPositions[index] - markerPositions[previousIndex])
                          .distance;
                  animationDouble = map(
                      dist.toInt(),
                      0,
                      (markerPositions.first - markerPositions.last)
                          .distance
                          .toInt(),
                      1000,
                      2500);

                  _controller.duration =
                      Duration(milliseconds: animationDouble);
                  _controller.forward();
                  // print(i);
                  // print('${markerPositions[i].dx}, ${markerPositions[i].dy}');

                  player.seek(Duration(
                      milliseconds: map(i, 0, markerPositions.length, 0,
                          geoFiles[selectedFileIndex].duration)));
                }

//--------------//

                // print(indexList[0].distance);

                // var transform =
                //     transformer.fromXYCoordsToLatLng(indexList[0].offset);

                // print(Geolocator.distanceBetween(
                //     location.latitude,
                //     location.longitude,
                //     transform.latitude,
                //     transform.longitude));
              },
              child: Listener(
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

                        final darkUrl =
                            'https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';
                        //Mapbox Streets
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
                    if (selectedFileIndex == 0)
                      Visibility(
                        visible: false,
                        child: AnimatedPositioned(
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
                                    child: Opacity(
                                      opacity: 1,
                                      child: Transform.rotate(
                                        angle: (angle) * 0.0174533,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Transform.rotate(
                                              angle: 180 * 0.0174533,
                                              child: const Icon(
                                                Icons.arrow_back,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: -105,
                                    left: 15,
                                    child: Transform.rotate(
                                      angle: 0 * 0.0174533,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        height: 100,
                                        color: Colors.grey,
                                        child: FittedBox(
                                            child: Center(
                                          child: Stack(
                                            // clipBehavior: Clip.antiAlias,
                                            children: [
                                              Text(index.toString()),
                                              videoPlayer(player)
                                            ],
                                          ),
                                        )),
                                      ),
                                    ))
                              ],
                            )),
                      ),
                    AnimatedBuilder(
                        child: Container(
                          width: 15,
                          height: 15,
                          color: Colors.red,
                        ),
                        animation: _controller,
                        builder: (context, child) {
                          print(_controller.duration?.inMilliseconds);
                          // print('$index $previousIndex');
                          var current;
                          if (index >= previousIndex) {
                            current = mapDouble(
                                    x: _controller.value * 10,
                                    in_min: 0,
                                    in_max: 10,
                                    out_min: previousIndex.toDouble(),
                                    out_max: index.toDouble())
                                .toInt();
                          } else {
                            current = mapDouble(
                                    x: 10 - (_controller.value * 10),
                                    in_min: 0,
                                    in_max: 10,
                                    out_min: index.toDouble(),
                                    out_max: previousIndex.toDouble())
                                .toInt();
                          }

                          // if (index < previousIndex) {
                          //   current = (previousIndex + index) - current;
                          //   // print(markerPositions[current]);
                          // }

                          return AnimatedPositioned(
                              duration: Duration(milliseconds: 10),
                              left: markerPositions[current].dx - 8,
                              top: markerPositions[current].dy - 8,
                              child: child!);
                        })
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
