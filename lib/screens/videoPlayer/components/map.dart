// ignore_for_file: non_constant_identifier_names

import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/models/GeofileClass.dart';
import 'package:gpmf/utilities/exporter.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:gpmf/screens/videoPlayer/components/paintpath.dart';
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
  const MapScreen(
      {Key? key,
      this.mapController,
      required this.geoFile,
      required this.leftPlayerController,
      required this.rightPlayerController,
      required this.skipDuplicateProvider,
      required this.duplicateAlertProvider,
      required this.mode,
      this.interactive = false})
      : super(key: key);
  final MapController? mapController;
  //final List<GeoFile>? geoFiles;
  final Provider<Player> leftPlayerController, rightPlayerController;
  final StateProvider<List<GeoFile>> geoFile;
  final StateProvider<bool> skipDuplicateProvider, duplicateAlertProvider;
  final bool interactive, mode;

  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> with SingleTickerProviderStateMixin {
  int index = 0, selectedFileIndex = 0, previousIndex = 0;
  bool isAnimation = true, follow = false;
  int counter = 0, animationDouble = 1500;
  double angle = 186, previousAngle = 0, testAngle = 0, prevTestAngle = 0;
  late MapTransformer mainTransformer;
  late AnimationController _controller;

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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    //widget.mapController?.dispose();

    super.dispose();
  }

  void _onDoubleTap() {
    isAnimation = false;
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      setState(() {
        isAnimation = true;
      });
    });
    // print(isAnimation);
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
    Future.delayed(const Duration(milliseconds: 500))
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
  //   //if (prev != null) print('${pos} ${prev}');
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
            var skipDuplicate =
                ref.read(widget.skipDuplicateProvider.state).state;
            if (skipDuplicate) {
              if (geoFiles[selectedFileIndex].geoData[localIndex].duplicate) {
                ref.read(widget.duplicateAlertProvider.state).state = true;
                player.pause();
                for (int i = localIndex;
                    i < geoFiles[selectedFileIndex].geoData.length;
                    i++) {
                  if (!geoFiles[selectedFileIndex].geoData[i].duplicate) {
                    localIndex = i;
                    player.seek(Duration(
                        milliseconds: map(
                            i,
                            0,
                            geoFiles[selectedFileIndex].geoData.length,
                            0,
                            geoFiles[selectedFileIndex].duration)));

                    Future.delayed(const Duration(microseconds: 10), () {
                      player.play();
                    });
                    break;
                  }
                }
                ref.read(widget.duplicateAlertProvider.state).state = false;
              }
            } else {
              if (geoFiles[selectedFileIndex].geoData[localIndex].duplicate) {
                // print("here");
                ref.read(widget.duplicateAlertProvider.state).state = true;
              } else {
                ref.read(widget.duplicateAlertProvider.state).state = false;
              }
            }

            Offset x = mainTransformer.fromLatLngToXYCoords(LatLng(
                geoFiles[selectedFileIndex].geoData[localIndex].lat,
                geoFiles[selectedFileIndex].geoData[localIndex].lng));

            Rect visibleScreen;

            visibleScreen = Rect.fromLTWH(
                50,
                50,
                mainTransformer.constraints.maxWidth - 50,
                mainTransformer.constraints.maxHeight - 50);

            // print(
            //     "$x \n ${visibleScreen.topLeft} ${visibleScreen.topRight} ${visibleScreen.bottomLeft} ${visibleScreen.bottomRight}");
            var visble = (visibleScreen.contains(x));

            // var l = mainTransformer
            //     .fromXYCoordsToLatLng(Offset(0, constraint.maxWidth));
            // print("${l.latitude} ${l.longitude}");

            if (!visble) {
              setState(() {
                isAnimation = false;
              });
              Future.delayed(const Duration(milliseconds: 250))
                  .then((value) => setState(() => (isAnimation = true)));
              widget.mapController?.center = LatLng(
                  geoFiles[selectedFileIndex].geoData[localIndex].lat,
                  geoFiles[selectedFileIndex].geoData[localIndex].lng);
            }

            setState(() {
              previousIndex = index;
              index = localIndex;
            });

            // player.takeSnapshot(file, 200, 200);
            // index = localIndex;
            if (follow) {
              setState(() {
                isAnimation = true;
              });
              widget.mapController?.center = LatLng(
                  geoFiles[selectedFileIndex].geoData[index].lat,
                  geoFiles[selectedFileIndex].geoData[index].lng);
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
                    transformer.fromLatLngToXYCoords(LatLng(e.lat, e.lng)))
                .toList();
            // widget.markers?.map(transformer.fromLatLngToXYCoords).toList();

            if (index > 0 && index < geoFiles[0].geoData.length) {
              // angle = math.atan(
              //     (markerPositions[index + 9].dy - markerPositions[index].dy) /
              //         ((markerPositions[index + 9].dx -
              //             markerPositions[index].dx)));
              previousAngle = angle;
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
            //print(angle);
            prevTestAngle = testAngle;
            if (angle > -15 && angle < 45)
              testAngle = 270;
            else if (angle > -195 && angle < -135)
              testAngle = 90;
            else if (angle > -110 && angle < -45)
              testAngle = 360;
            else if (angle < 135 && angle > 45) testAngle = 180;

            // print((testAngle - prevTestAngle) / 360);

            return AnimatedRotation(
              turns: widget.interactive ? ((testAngle) / 360) : 0,
              duration: Duration(milliseconds: 2000),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _onDoubleTap,
                onScaleStart: !widget.interactive ? _onScaleStart : (v) {},
                onScaleUpdate: !widget.interactive ? _onScaleUpdate : (v) {},
                onTapUp: (details) {
                  _controller.reset();
                  setState(() {
                    isAnimation = true;
                  });
                  final location =
                      transformer.fromXYCoordsToLatLng(details.localPosition);

                  List<GeoFile> selected = [];
                  for (var element in geoFiles) {
                    if (element.boundingBox!.contains(
                        Offset(location.latitude, location.longitude))) {
                      selected.add(element);
                    }
                  }

                  final clicked = transformer.fromLatLngToXYCoords(location);

                  // var matchGreat = markerPositions
                  //     .where((e) => e.dx >= clicked.dx && e.dy >= clicked.dy)
                  //     .toList();
                  // var matchLess = markerPositions
                  //     .where((e) => e.dx <= clicked.dx && e.dy <= clicked.dy)
                  //     .toList();

                  List<SelectorCompare> selection = [];
                  for (var element in selected) {
                    final markerPositions = element.geoData
                        .map((e) => transformer
                            .fromLatLngToXYCoords(LatLng(e.lat, e.lng)))
                        .toList();
                    var indexList = markerPositions
                        .map((e) => CompareOffset(
                            offset: e, distance: (e - clicked).distance))
                        .toList();
                    indexList.sort((a, b) => a.distance.compareTo(b.distance));
                    selection.add(SelectorCompare(
                        compareOffset: indexList[0], file: element));
                  }

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

                    var dist = (markerPositions[index] -
                            markerPositions[previousIndex])
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
                    var skipDuplicate =
                        ref.read(widget.skipDuplicateProvider.state).state;
                    // if (skipDuplicate) {
                    //   if (geoFiles[selectedFileIndex].geoData[i].duplicate) {
                    //     player.pause();
                    //     for (int j = i;
                    //         j < geoFiles[selectedFileIndex].geoData.length;
                    //         j++) {
                    //       if (!geoFiles[selectedFileIndex].geoData[j].duplicate) {
                    //         //localIndex = i;
                    //         player.seek(Duration(
                    //             milliseconds: map(
                    //                 j,
                    //                 0,
                    //                 geoFiles[selectedFileIndex].geoData.length,
                    //                 0,
                    //                 geoFiles[selectedFileIndex].duration)));

                    //         // Future.delayed(const Duration(microseconds: 10), () {
                    //         //   player.play();
                    //         // });
                    //         break;
                    //       }
                    //     }
                    //   }
                    // }
                    // else
                    {
                      player.seek(Duration(
                          milliseconds: map(i, 0, markerPositions.length, 0,
                              geoFiles[selectedFileIndex].duration)));
                    }

                    setState(() {
                      previousIndex = index;
                      index = i;
                    });
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

                      Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => setState(() => (isAnimation = true)));
                    }
                  },
                  child: SizedBox(
                    width: constraint.maxWidth,
                    height: constraint.maxHeight,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: constraint.maxWidth,
                          height: constraint.maxHeight,
                        ),
                        AnimatedRotation(
                          turns: 0,
                          //turns: 0,
                          // turns: 1 / (1 / (testAngle * 0.0174533)) -
                          //     1 / (1 / prevTestAngle * 0.0174533),

                          // angle: testAngle * 0.0174533,
                          duration: Duration(milliseconds: 2000),
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
                              if (selectedFileIndex == 0)
                                Visibility(
                                  visible: true,
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
                                                    spreadRadius: 0.5,
                                                    blurRadius: 5)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Opacity(
                                                opacity: 1,
                                                child: AnimatedRotation(
                                                  turns: (angle) / 360,
                                                  duration: const Duration(
                                                      milliseconds: 500),
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
                                          Visibility(
                                            visible: false,
                                            // !widget.interactive,
                                            child: Positioned(
                                                top: -35,
                                                left: 15,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  height: 30,
                                                  color: Colors.grey,
                                                  child: FittedBox(
                                                      child: Center(
                                                    child: Stack(
                                                      // clipBehavior: Clip.antiAlias,
                                                      children: [
                                                        Text(index.toString()),
                                                        // Visibility(
                                                        //     visible: false,
                                                        //     child: videoPlayer(player))
                                                      ],
                                                    ),
                                                  )),
                                                )),
                                          )
                                        ],
                                      )),
                                ),
                              Visibility(
                                visible: false,
                                child: AnimatedBuilder(
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      color: Colors.red,
                                    ),
                                    animation: _controller,
                                    builder: (context, child) {
                                      // print(_controller.duration?.inMilliseconds);
                                      // print('$index $previousIndex');
                                      var current = 0;
                                      if (index >= previousIndex) {
                                        current = mapDouble(
                                                x: _controller.value * 10,
                                                in_min: 0,
                                                in_max: 10,
                                                out_min:
                                                    previousIndex.toDouble(),
                                                out_max: index.toDouble())
                                            .toInt();
                                      } else {
                                        current = mapDouble(
                                                x: 10 -
                                                    (_controller.value * 10),
                                                in_min: 0,
                                                in_max: 10,
                                                out_min: index.toDouble(),
                                                out_max:
                                                    previousIndex.toDouble())
                                            .toInt();
                                      }

                                      // if (index < previousIndex) {
                                      //   current = (previousIndex + index) - current;
                                      //   // print(markerPositions[current]);
                                      // }

                                      return AnimatedPositioned(
                                          duration:
                                              const Duration(milliseconds: 10),
                                          left: markerPositions[current].dx - 8,
                                          top: markerPositions[current].dy - 8,
                                          child: child!);
                                    }),
                              ),

                              // centerMarkerWidget,
                            ],
                          ),
                        ),
                        Visibility(
                          visible: false,
                          child: Positioned(
                            right: 0,
                            bottom: 0,
                            child: Slider(
                              value: testAngle,
                              onChanged: (v) {
                                setState(() {
                                  testAngle = v;
                                  print(v);
                                });
                              },
                              min: 0,
                              max: 360,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
    });
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
